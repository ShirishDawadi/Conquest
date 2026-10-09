import 'dart:async';
import 'dart:developer';
import 'package:conquest/core/services/location_service.dart';
import 'package:conquest/core/services/map_sync_service.dart';
import 'package:conquest/core/utils/connectivity_utils.dart';
import 'package:conquest/data/models/gps_model.dart';
import 'package:conquest/data/models/map_state.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:conquest/presentation/viewmodels/summary_viewmodel.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import 'package:permission_handler/permission_handler.dart';

enum StartTrackingResult { started, sessionLimit, permissionDenied, failed }

class MapViewModel extends Notifier<MapState> {
  final _locationService = LocationService();
  final _syncService = MapSyncService();

  static const _distanceCalc = Distance();

  StreamSubscription<List<GpsPoint>>? _pointSubscription;
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;
  Timer? _durationTimer;
  int _loadGeneration = 0;
  bool _isMonthView = false;

  static const _maxSessionDuration = Duration(hours: 12);
  bool _autoStopping = false;

  Duration get elapsed => _locationService.elapsed;

  @override
  MapState build() {
    final today = DateTime.now();
    final initialState = MapState(
      selectedDate: DateTime(today.year, today.month, today.day),
    );

    _connectivitySubscription = Connectivity().onConnectivityChanged.listen((
      result,
    ) {
      if (!result.contains(ConnectivityResult.none)) {
        _syncService.retryUnsynced();
      }
    });

    _pointSubscription = _locationService.pointStream.listen((points) {
      double furthest = state.furthestDistanceKm;
      if (points.isNotEmpty) {
        final start = points.first.toLatLng();
        final latest = points.last.toLatLng();
        final radialKm = _distanceCalc(start, latest) / 1000;
        if (radialKm > furthest) furthest = radialKm;
      }

      state = state.copyWith(
        currentPoints: points,
        furthestDistanceKm: furthest,
      );
    });

    ref.onDispose(() {
      _pointSubscription?.cancel();
      _connectivitySubscription?.cancel();
      _durationTimer?.cancel();
    });

    Future.microtask(() {
      _loadLog(initialState.selectedDate);
      _syncService.cleanOldSessions();
    });

    return initialState;
  }

  Future<void> loadForCurrentView({required bool isMonthView}) async {
    if (isMonthView) {
      await _loadMonthLog(state.selectedDate);
    } else {
      await _loadLog(state.selectedDate);
    }
  }

  Future<void> _loadLog(DateTime date) async {
    _isMonthView = false;
    final gen = ++_loadGeneration;
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final gpsLog = await _syncService.getLog(date);
      if (gen != _loadGeneration) return;

      if (gpsLog == null && !await ConnectivityUtils.isOnline()) {
        state = state.copyWith(
          clearDayLog: true,
          isLoading: false,
          error: 'No internet connection',
        );
        return;
      }

      state = state.copyWith(
        dayLog: gpsLog,
        clearDayLog: gpsLog == null,
        isLoading: false,
      );
    } catch (e) {
      if (gen != _loadGeneration) return;
      log('MapViewModel _loadLog failed: $e', name: 'MapViewModel');
      state = state.copyWith(
        isLoading: false,
        error: 'Couldn\'t load sessions',
      );
    }
  }

  Future<void> _loadMonthLog(DateTime date) async {
    _isMonthView = true;
    final gen = ++_loadGeneration;
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final gpsLog = await _syncService.getMonthLog(date);
      if (gen != _loadGeneration) return;

      if (gpsLog == null && !await ConnectivityUtils.isOnline()) {
        state = state.copyWith(
          clearDayLog: true,
          isLoading: false,
          error: 'No internet connection',
        );
        return;
      }

      state = state.copyWith(
        dayLog: gpsLog,
        clearDayLog: gpsLog == null,
        isLoading: false,
      );
    } catch (e) {
      if (gen != _loadGeneration) return;
      log('MapViewModel _loadLog failed: $e', name: 'MapViewModel');
      state = state.copyWith(
        isLoading: false,
        error: 'Couldn\'t load sessions',
      );
    }
  }

  Future<void> checkPermissions() async {
    final result = await _locationService.requestPermissions();
    state = state.copyWith(permissionStatus: _mapResult(result));
  }

  Future<StartTrackingResult> startTracking() async {
    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);

    final count = await _syncService.getSessionCountForDate(todayDate);
    if (count >= 10) return StartTrackingResult.sessionLimit;

    await Permission.notification.request();

    final permissionResult = await _locationService.requestPermissions();
    if (permissionResult != LocationPermissionResult.granted) {
      state = state.copyWith(permissionStatus: _mapResult(permissionResult));
      return StartTrackingResult.permissionDenied;
    }

    final started = await _locationService.startTracking();
    if (!started) {
      state = state.copyWith(permissionStatus: LocationPermissionStatus.denied);
      return StartTrackingResult.failed;
    }

    _startDurationTimer();

    state = state.copyWith(
      isTracking: true,
      currentPoints: [],
      furthestDistanceKm: 0,
      sessionStart: _locationService.sessionStart,
      permissionStatus: LocationPermissionStatus.granted,
      clearError: true,
    );

    return StartTrackingResult.started;
  }

  LocationPermissionStatus _mapResult(LocationPermissionResult r) {
    switch (r) {
      case LocationPermissionResult.granted:
        return LocationPermissionStatus.granted;
      case LocationPermissionResult.serviceDisabled:
        return LocationPermissionStatus.serviceDisabled;
      case LocationPermissionResult.denied:
        return LocationPermissionStatus.denied;
      case LocationPermissionResult.deniedForever:
        return LocationPermissionStatus.deniedForever;
    }
  }

  Future<void> stopTracking() async {
    _durationTimer?.cancel();
    _durationTimer = null;

    state = state.copyWith(isTracking: false);

    try {
      final rawSession = await _locationService.stopTracking();
      if (rawSession == null) {
        state = state.copyWith(clearFocusedSession: true);
        return;
      }

      final session = rawSession.copyWith(
        furthestDistanceKm: state.furthestDistanceKm,
      );

      final started = session.startedAt;
      final startDate = DateTime(started.year, started.month, started.day);

      final savedSession = await _syncService.saveAndSync(startDate, session);

      final selected = state.selectedDate;
      final sameMonth =
          selected.year == startDate.year && selected.month == startDate.month;
      final visible = _isMonthView
          ? sameMonth
          : sameMonth && selected.day == startDate.day;

      state = state.copyWith(
        currentPoints: [],
        furthestDistanceKm: 0,
        sessionStart: null,
        dayLog: visible
            ? GpsLog(
                date: state.dayLog?.date ?? state.selectedDate,
                sessions: [...(state.dayLog?.sessions ?? []), savedSession],
              )
            : null,
        focusedSession: visible ? savedSession : null,
      );

      ref.invalidate(daySummaryProvider(startDate));
    } catch (e) {
      state = state.copyWith(isTracking: true);
      _startDurationTimer();
      rethrow;
    }
  }

  void navigateDate(int days) {
    final newDate = state.selectedDate.add(Duration(days: days));
    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);
    if (newDate.isAfter(todayDate)) return;

    state = state.copyWith(
      selectedDate: newDate,
      clearFocusedSession: true,
      clearDayLog: true,
    );
    _loadLog(newDate);
  }

  void navigateMonth(int months) {
    final d = state.selectedDate;
    final newDate = DateTime(d.year, d.month + months, 1);
    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);
    if (newDate.isAfter(todayDate)) return;

    state = state.copyWith(
      selectedDate: newDate,
      clearFocusedSession: true,
      clearDayLog: true,
    );
    _loadMonthLog(newDate);
  }

  void focusSession(GpsSession session) {
    state = state.copyWith(focusedSession: session);
  }

  void clearFocus() {
    state = state.copyWith(clearFocusedSession: true);
  }

  void _startDurationTimer() {
    _durationTimer?.cancel();
    _durationTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      final start = _locationService.sessionStart;
      if (start != null && _locationService.elapsed >= _maxSessionDuration) {
        _autoStop();
        return;
      }
      state = state.copyWith(sessionStart: start);
    });
  }

  Future<void> _autoStop() async {
    if (_autoStopping) return;
    _autoStopping = true;
    try {
      await stopTracking();
    } catch (e) {
      log('MapViewModel auto-stop failed: $e', name: 'MapViewModel');
    } finally {
      _autoStopping = false;
    }
  }

  Future<void> deleteSession(GpsSession session) async {
    final updatedSessions = state.dayLog?.sessions
        .where(
          (s) =>
              (s.backendId ?? s.localId) !=
              (session.backendId ?? session.localId),
        )
        .toList();

    if (updatedSessions == null) return;

    if (updatedSessions.isEmpty) {
      state = state.copyWith(clearDayLog: true, clearFocusedSession: true);
    } else {
      final updatedLog = GpsLog(
        date: state.selectedDate,
        sessions: updatedSessions,
      );
      state = state.copyWith(dayLog: updatedLog, clearFocusedSession: true);
    }

    await _syncService.deleteSession(session, state.selectedDate);

    ref.invalidate(daySummaryProvider(state.selectedDate));
  }

  Future<void> refresh() async {
    if (_isMonthView) return _loadMonthLog(state.selectedDate);
    final gen = ++_loadGeneration;
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final gpsLog = await _syncService.refreshLog(state.selectedDate);
      if (gen != _loadGeneration) return;

      if (gpsLog == null && !await ConnectivityUtils.isOnline()) {
        state = state.copyWith(
          clearDayLog: true,
          isLoading: false,
          error: 'No internet connection',
        );
        return;
      }

      state = state.copyWith(
        dayLog: gpsLog,
        clearDayLog: gpsLog == null,
        isLoading: false,
      );
    } catch (e) {
      if (gen != _loadGeneration) return;
      state = state.copyWith(isLoading: false, error: 'Failed to load map');
    }
  }
}

final mapProvider = NotifierProvider<MapViewModel, MapState>(MapViewModel.new);

final liveSessionDistanceMetersProvider = Provider<double>((ref) {
  final furthestKm = ref.watch(mapProvider.select((s) => s.furthestDistanceKm));
  return furthestKm * 1000;
});

final bestSessionTodayKmProvider = Provider<double?>((ref) {
  final dayLog = ref.watch(mapProvider.select((s) => s.dayLog));
  final sessions = dayLog?.sessions ?? [];
  if (sessions.isEmpty) return null;

  return sessions
      .map((s) => s.furthestDistanceKm)
      .reduce((a, b) => a > b ? a : b);
});
