import 'dart:async';
import 'dart:developer';
import 'dart:math' as math;
import 'package:conquest/core/services/step_service.dart';
import 'package:conquest/core/theme/app_colors.dart';
import 'package:conquest/core/utils/tracking_utils.dart';
import 'package:conquest/data/models/gps_model.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:geolocator/geolocator.dart';

enum LocationPermissionResult {
  granted,
  serviceDisabled,
  denied,
  deniedForever,
}

class LocationService {
  static final LocationService _instance = LocationService._internal();
  factory LocationService() => _instance;
  LocationService._internal();

  StreamSubscription<Position>? _positionSubscription;
  Timer? _notificationTimer;
  final List<GpsPoint> _currentPoints = [];
  DateTime? _sessionStart;
  final Stopwatch _stopwatch = Stopwatch();
  Duration get elapsed => _stopwatch.elapsed;
  bool _isTracking = false;
  double _lastSpeedKmh = 0.0;
  double _movingSeconds = 0;
  DateTime? _lastEventTime;
  int _startSteps = 0;
  final List<double> _altWindow = [];
  double? _refAlt;
  double _elevGain = 0;
  double _elevLoss = 0;

  bool get isTracking => _isTracking;
  List<GpsPoint> get currentPoints => List.unmodifiable(_currentPoints);
  DateTime? get sessionStart => _sessionStart;

  final _pointController = StreamController<List<GpsPoint>>.broadcast();
  Stream<List<GpsPoint>> get pointStream => _pointController.stream;

  Future<void> initialize() async {
    FlutterForegroundTask.init(
      androidNotificationOptions: AndroidNotificationOptions(
        channelId: 'conquest_tracking',
        channelName: 'Conquest Tracking',
        channelDescription: 'Conquest is tracking your route',
        channelImportance: NotificationChannelImportance.LOW,
        priority: NotificationPriority.LOW,
      ),
      iosNotificationOptions: const IOSNotificationOptions(
        showNotification: true,
        playSound: false,
      ),
      foregroundTaskOptions: ForegroundTaskOptions(
        eventAction: ForegroundTaskEventAction.repeat(3000),
        autoRunOnBoot: false,
        allowWifiLock: false,
      ),
    );
  }

  Future<LocationPermissionResult> requestPermissions() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return LocationPermissionResult.serviceDisabled;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return LocationPermissionResult.denied;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return LocationPermissionResult.deniedForever;
    }

    return LocationPermissionResult.granted;
  }

  Future<bool> startTracking() async {
    if (_isTracking) return true;

    final result = await requestPermissions();
    if (result != LocationPermissionResult.granted) return false;

    _currentPoints.clear();
    _lastSpeedKmh = 0.0;
    _movingSeconds = 0;
    _lastEventTime = null;
    _startSteps = StepService().todaySteps;
    _altWindow.clear();
    _refAlt = null;
    _elevGain = 0;
    _elevLoss = 0;
    _sessionStart = DateTime.now();
    _stopwatch
      ..reset()
      ..start();
    _isTracking = true;

    await FlutterForegroundTask.startService(
      serviceId: 1000,
      notificationTitle: 'Conquest',
      notificationText: 'Tracking your route...',
      notificationIcon: const NotificationIcon(
        metaDataName: 'conquest_tracking_icon',
        backgroundColor: AppColors.greenish_2,
      ),
    );

    _positionSubscription =
        Geolocator.getPositionStream(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.high,
          ),
        ).listen(
          _onPosition,
          onError: (e) =>
              log('Position stream error: $e', name: 'LocationService'),
        );

    _notificationTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!_isTracking) return;
      final elapsed = _stopwatch.elapsed;
      final distanceStr = TrackingUtils.distanceKm(
        _currentPoints,
      ).toStringAsFixed(2);
      final timeStr = TrackingUtils.formatDuration(elapsed);
      FlutterForegroundTask.updateService(
        notificationTitle: 'Conquest',
        notificationText:
            '${_lastSpeedKmh.toStringAsFixed(1)}km/h • ${distanceStr}km • $timeStr',
      );
    });

    log('Tracking started', name: 'LocationService');
    return true;
  }

  void _trackMoving(Position position) {
    final t = position.timestamp;
    final last = _lastEventTime;
    if (last != null) {
      final dt = t.difference(last).inMilliseconds / 1000;
      if (dt > 0 && dt <= 15 && position.speed >= 0.5) _movingSeconds += dt;
    }
    _lastEventTime = t;
  }

  void _trackElevation(Position position) {
    if (position.altitude == 0.0) return;
    _altWindow.add(position.altitude);
    if (_altWindow.length > 5) _altWindow.removeAt(0);
    final avg = _altWindow.reduce((a, b) => a + b) / _altWindow.length;

    final ref = _refAlt;
    if (ref == null) {
      _refAlt = avg;
      return;
    }
    final diff = avg - ref;
    if (diff >= 3) {
      _elevGain += diff;
      _refAlt = avg;
    } else if (diff <= -3) {
      _elevLoss += -diff;
      _refAlt = avg;
    }
  }

  void _onPosition(Position position) {
    if (position.accuracy > 20.0) return;

    _trackMoving(position);
    _trackElevation(position);

    if (_currentPoints.isNotEmpty) {
      final last = _currentPoints.last;
      final movedMeters = Geolocator.distanceBetween(
        last.lat,
        last.lng,
        position.latitude,
        position.longitude,
      );

      if (movedMeters < position.accuracy * 0.5) {
        return;
      }
    }

    final point = GpsPoint(lat: position.latitude, lng: position.longitude);
    _lastSpeedKmh = (position.speed * 3.6).clamp(0.0, double.infinity);
    _currentPoints.add(point);
    _pointController.add(List.unmodifiable(_currentPoints));
  }

  Future<GpsSession?> stopTracking() async {
    if (!_isTracking) return null;

    _stopwatch.stop();
    final elapsed = _stopwatch.elapsed;
    await _positionSubscription?.cancel();
    _positionSubscription = null;
    _notificationTimer?.cancel();
    _notificationTimer = null;
    _isTracking = false;

    await FlutterForegroundTask.stopService();

    if (_currentPoints.isEmpty) {
      log('No points recorded', name: 'LocationService');
      return null;
    }

    final steps = StepService().mode == StepTrackingMode.unavailable
        ? 0
        : math.max(0, StepService().todaySteps - _startSteps);

    final session = GpsSession(
      startedAt: _sessionStart!,
      endedAt: _sessionStart!.add(elapsed),
      points: List.from(_currentPoints),
      distanceKm: TrackingUtils.distanceKm(_currentPoints),
      movingSeconds: math.min(_movingSeconds.round(), elapsed.inSeconds),
      steps: steps,
      elevationGain: _elevGain,
      elevationLoss: _elevLoss,
    );

    _currentPoints.clear();
    _lastSpeedKmh = 0.0;
    _sessionStart = null;

    log(
      'Tracking stopped — ${session.points.length} points, ${session.distanceKm.toStringAsFixed(2)}km',
      name: 'LocationService',
    );

    return session;
  }

  Future<Position?> getCurrentPosition() async {
    try {
      return await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );
    } catch (e) {
      log('getCurrentPosition failed: $e', name: 'LocationService');
      return null;
    }
  }

  void dispose() {
    _positionSubscription?.cancel();
    _notificationTimer?.cancel();
    _pointController.close();
  }
}
