import 'dart:async';
import 'dart:developer';
import 'package:conquest/core/theme/app_colors.dart';
import 'package:conquest/core/utils/tracking_utils.dart';
import 'package:conquest/data/models/gps_model.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:geolocator/geolocator.dart';

class LocationService {
  static final LocationService _instance = LocationService._internal();
  factory LocationService() => _instance;
  LocationService._internal();

  StreamSubscription<Position>? _positionSubscription;
  Timer? _notificationTimer;
  final List<GpsPoint> _currentPoints = [];
  DateTime? _sessionStart;
  bool _isTracking = false;
  double _lastSpeedKmh = 0.0;


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

  Future<bool> requestPermissions() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return false;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return false;
    }

    if (permission == LocationPermission.deniedForever) return false;

    return true;
  }

  Future<bool> startTracking() async {
    if (_isTracking) return true;

    final hasPermission = await requestPermissions();
    if (!hasPermission) return false;

    _currentPoints.clear();
    _lastSpeedKmh = 0.0;
    _sessionStart = DateTime.now();
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
      final elapsed = DateTime.now().difference(_sessionStart!);
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

  void _onPosition(Position position) {
    if (position.accuracy > 20.0) return;

    final point = GpsPoint(lat: position.latitude, lng: position.longitude);
    _lastSpeedKmh = (position.speed * 3.6).clamp(0.0, double.infinity);
    _currentPoints.add(point);
    _pointController.add(List.unmodifiable(_currentPoints));
  }

  Future<GpsSession?> stopTracking() async {
    if (!_isTracking) return null;

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

    final session = GpsSession(
      startedAt: _sessionStart!,
      endedAt: DateTime.now(),
      points: List.from(_currentPoints),
      distanceKm: TrackingUtils.distanceKm(_currentPoints),
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
