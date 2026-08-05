import 'dart:async';
import 'dart:developer';
import 'package:conquest/core/services/location_service.dart';
import 'package:conquest/core/services/map_sync_service.dart';
import 'package:conquest/data/models/gps_model.dart';
import 'package:conquest/data/models/map_state.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import 'package:permission_handler/permission_handler.dart';

class MapViewModel extends Notifier<MapState> {
  final _locationService = LocationService();
  final _syncService = MapSyncService();

  static const _distanceCalc = Distance();

  StreamSubscription<List<GpsPoint>>? _pointSubscription;
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;
  Timer? _durationTimer;
  int _loadGeneration = 0;

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

  Future<void> _loadLog(DateTime date) async {
    final gen = ++_loadGeneration;
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final gpsLog = await _syncService.getLog(date);
      if (gen != _loadGeneration) return;
      state = state.copyWith(dayLog: gpsLog, isLoading: false);
    } catch (e) {
      if (gen != _loadGeneration) return;
      log('MapViewModel _loadLog failed: $e', name: 'MapViewModel');
      state = state.copyWith(isLoading: false, error: 'Failed to load map');
    }
  }

  Future<void> _loadMonthLog(DateTime date) async {
    final gen = ++_loadGeneration;
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final gpsLog = await _syncService.getMonthLog(date);
      if (gen != _loadGeneration) return;
      state = state.copyWith(dayLog: gpsLog, isLoading: false);
    } catch (e) {
      if (gen != _loadGeneration) return;
      log('MapViewModel _loadLog failed: $e', name: 'MapViewModel');
      state = state.copyWith(isLoading: false, error: 'Failed to load map');
    }
  }

  Future<void> checkPermissions() async {
    final granted = await _locationService.requestPermissions();
    state = state.copyWith(
      permissionStatus: granted
          ? LocationPermissionStatus.granted
          : LocationPermissionStatus.denied,
    );
  }

  Future<bool> startTracking() async {
    await Permission.notification.request();
    final started = await _locationService.startTracking();
    if (!started) {
      state = state.copyWith(permissionStatus: LocationPermissionStatus.denied);
      return false;
    }

    _durationTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      state = state.copyWith(sessionStart: _locationService.sessionStart);
    });

    state = state.copyWith(
      isTracking: true,
      currentPoints: [],
      furthestDistanceKm: 0, 
      sessionStart: _locationService.sessionStart,
    );

    return true;
  }

  Future<void> stopTracking() async {
    _durationTimer?.cancel();
    _durationTimer = null;

    final rawSession = await _locationService.stopTracking();
    if (rawSession == null) {
      state = state.copyWith(isTracking: false, clearFocusedSession: true);
      return;
    }

    final session = rawSession.copyWith(
      furthestDistanceKm: state.furthestDistanceKm,
    );

    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);

    final savedSession = await _syncService.saveAndSync(todayDate, session);

    final existingSessions = state.dayLog?.sessions ?? [];
    final updatedSessions = [...existingSessions, savedSession];
    final updatedLog = GpsLog(date: todayDate, sessions: updatedSessions);

    state = state.copyWith(
      isTracking: false,
      currentPoints: [],
      furthestDistanceKm: 0,
      sessionStart: null,
      dayLog: updatedLog,
      focusedSession: savedSession,
    );
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
  }

  Future<void> refresh() async {
    final gen = ++_loadGeneration;
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final gpsLog = await _syncService.refreshLog(state.selectedDate);
      if (gen != _loadGeneration) return;
      state = state.copyWith(dayLog: gpsLog, isLoading: false);
    } catch (e) {
      if (gen != _loadGeneration) return;
      state = state.copyWith(isLoading: false, error: 'Failed to load map');
    }
  }
}

final mapProvider = NotifierProvider<MapViewModel, MapState>(MapViewModel.new);

final liveSessionDistanceMetersProvider = Provider<double>((ref) {
  final furthestKm = ref.watch(
    mapProvider.select((s) => s.furthestDistanceKm),
  );
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