import 'dart:async';
import 'dart:developer';
import 'package:conquest/data/models/gps_model.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:geolocator/geolocator.dart';

class LocationService {
  static final LocationService _instance = LocationService._internal();
  factory LocationService() => _instance;
  LocationService._internal();

  StreamSubscription<Position>? _positionSubscription;
  final List<GpsPoint> _currentPoints = [];
  DateTime? _sessionStart;
  bool _isTracking = false;

  static const _minDistanceMeters = 5.0;
  GpsPoint? _lastPoint;

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
    _lastPoint = null;
    _sessionStart = DateTime.now();
    _isTracking = true;

    await FlutterForegroundTask.startService(
      serviceId: 1000,
      notificationTitle: 'Conquest',
      notificationText: 'Tracking your route...',
    );

    _positionSubscription = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 5, 
      ),
    ).listen(
      _onPosition,
      onError: (e) => log('Position stream error: $e', name: 'LocationService'),
    );

    log('Tracking started', name: 'LocationService');
    return true;
  }

  void _onPosition(Position position) {
    final point = GpsPoint(lat: position.latitude, lng: position.longitude);

    if (_lastPoint != null) {
      final distance = Geolocator.distanceBetween(
        _lastPoint!.lat,
        _lastPoint!.lng,
        point.lat,
        point.lng,
      );
      if (distance < _minDistanceMeters) return;
    }

    _lastPoint = point;
    _currentPoints.add(point);
    _pointController.add(List.unmodifiable(_currentPoints));

    final session = GpsSession(
      sessionId: 0,
      startedAt: _sessionStart!,
      points: _currentPoints,
    );
    final distanceStr = session.distanceKm.toStringAsFixed(2);
    FlutterForegroundTask.updateService(
      notificationTitle: 'Conquest',
      notificationText: '${distanceStr}km tracked',
    );
  }

  Future<GpsSession?> stopTracking() async {
    if (!_isTracking) return null;

    await _positionSubscription?.cancel();
    _positionSubscription = null;
    _isTracking = false;

    await FlutterForegroundTask.stopService();

    if (_currentPoints.isEmpty) {
      log('No points recorded', name: 'LocationService');
      return null;
    }

    final session = GpsSession(
      sessionId: DateTime.now().millisecondsSinceEpoch,
      startedAt: _sessionStart!,
      endedAt: DateTime.now(),
      points: List.from(_currentPoints),
    );

    _currentPoints.clear();
    _lastPoint = null;
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
    _pointController.close();
  }
}