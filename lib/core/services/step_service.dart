import 'dart:async';
import 'dart:developer';
import 'package:health/health.dart';
import 'package:pedometer/pedometer.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum StepTrackingMode { health, pedometer, unavailable }

class StepService {
  static final StepService _instance = StepService._internal();
  factory StepService() => _instance;
  StepService._internal();

  final Health _health = Health();
  StreamSubscription<StepCount>? _pedometerSubscription;
  Timer? _healthPollTimer;

  StepTrackingMode _mode = StepTrackingMode.unavailable;
  int _todaySteps = 0;
  int _pedometerBaseline = 0;
  bool _initialized = false;
  Completer<void>? _baselineCompleter;

  StepTrackingMode get mode => _mode;
  int get todaySteps => _todaySteps;

  final _stepController = StreamController<int>.broadcast();
  Stream<int> get stepStream => _stepController.stream;

  void _safeAdd(int steps) {
    if (!_stepController.isClosed) _stepController.add(steps);
  }

  Future<void> initialize() async {
    if (_initialized) return;
    _initialized = true;

    final healthAvailable = await _tryInitHealth();
    if (!healthAvailable) await _tryInitPedometer();
  }

  Future<bool> _tryInitHealth() async {
    try {
      final types = [HealthDataType.STEPS];
      final permissions = [HealthDataAccess.READ];

      await _health.configure();

      final status = await _health.getHealthConnectSdkStatus();
      if (status != HealthConnectSdkStatus.sdkAvailable) return false;

      final hasPermsAlready = await _health.hasPermissions(
        types,
        permissions: permissions,
      );

      if (hasPermsAlready != true) {
        final requested = await _health.requestAuthorization(
          types,
          permissions: permissions,
        );
        if (!requested) return false;
      }

      final hasPerms = await _health.hasPermissions(
        types,
        permissions: permissions,
      );
      if (hasPerms != true) return false;

      return await _fetchInitialHealthSteps();
    } catch (e) {
      log('Health Connect init failed: $e', name: 'StepService');
      return false;
    }
  }

  Future<bool> _fetchInitialHealthSteps() async {
    try {
      final now = DateTime.now();
      final midnight = DateTime(now.year, now.month, now.day);
      final steps = await _health.getTotalStepsInInterval(midnight, now);

      if (steps != null) {
        _mode = StepTrackingMode.health;
        _todaySteps = steps;
        _safeAdd(_todaySteps);

        _healthPollTimer?.cancel();
        _healthPollTimer = Timer.periodic(const Duration(minutes: 5), (_) {
          if (_mode == StepTrackingMode.health) _fetchHealthSteps();
        });

        return true;
      }
      return false;
    } catch (e) {
      log('Initial health steps fetch failed: $e', name: 'StepService');
      return false;
    }
  }

  Future<void> _fetchHealthSteps() async {
    try {
      final now = DateTime.now();
      final midnight = DateTime(now.year, now.month, now.day);
      final steps = await _health.getTotalStepsInInterval(midnight, now);
      if (steps != null) {
        _todaySteps = steps;
        _safeAdd(_todaySteps);
      }
    } catch (e) {
      log('Health refresh failed: $e', name: 'StepService');
    }
  }

  Future<void> _tryInitPedometer() async {
    try {
      final status = await Permission.activityRecognition.request();
      if (!status.isGranted) {
        _mode = StepTrackingMode.unavailable;
        return;
      }

      _mode = StepTrackingMode.pedometer;

      _baselineCompleter = Completer<void>();
      await _loadPedometerBaseline();
      _baselineCompleter!.complete();

      await _pedometerSubscription?.cancel();

      _pedometerSubscription = Pedometer.stepCountStream.listen((event) async {
        await _baselineCompleter?.future;
        await _handlePedometerStep(event.steps);
      }, onError: (_) => _mode = StepTrackingMode.unavailable);
    } catch (e) {
      log('Pedometer init failed: $e', name: 'StepService');
      _mode = StepTrackingMode.unavailable;
    }
  }

  Future<void> _handlePedometerStep(int totalSteps) async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now().toIso8601String().substring(0, 10);
    final savedDate = prefs.getString('pedometer_date') ?? '';

    if (savedDate != today) {
      await prefs.setString('pedometer_date', today);
      await prefs.setInt('pedometer_baseline', totalSteps);
      _pedometerBaseline = totalSteps;
    }

    _todaySteps = (totalSteps - _pedometerBaseline).clamp(0, 999999);
    _safeAdd(_todaySteps);
  }

  Future<void> _loadPedometerBaseline() async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now().toIso8601String().substring(0, 10);
    final savedDate = prefs.getString('pedometer_date') ?? '';

    if (savedDate == today) {
      _pedometerBaseline = prefs.getInt('pedometer_baseline') ?? 0;
    }
  }

  Future<bool> get isHealthConnectAvailable async {
    final status = await _health.getHealthConnectSdkStatus();
    return status == HealthConnectSdkStatus.sdkAvailable;
  }

  Future<void> retryHealthConnect() async {
    try {
      final types = [HealthDataType.STEPS];
      final permissions = [HealthDataAccess.READ];

      final hasPerms = await _health.hasPermissions(
        types,
        permissions: permissions,
      );

      if (hasPerms != true) {
        _mode = StepTrackingMode.pedometer;
        _healthPollTimer?.cancel();
        await _tryInitPedometer();
        return;
      }

      await _pedometerSubscription?.cancel();
      _pedometerSubscription = null;
      _healthPollTimer?.cancel();

      final success = await _fetchInitialHealthSteps();
      if (!success) {
        _mode = StepTrackingMode.pedometer;
        await _tryInitPedometer();
      }
    } catch (e) {
      log('retryHealthConnect failed: $e', name: 'StepService');
    }
  }

  Future<void> refresh() async {
    if (_mode == StepTrackingMode.health) await _fetchHealthSteps();
  }

  void dispose() {
    _pedometerSubscription?.cancel();
    _healthPollTimer?.cancel();
    _stepController.close();
    _mode = StepTrackingMode.unavailable;
    _initialized = false;
  }
}
