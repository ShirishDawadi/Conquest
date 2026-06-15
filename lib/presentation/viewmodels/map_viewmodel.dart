import 'dart:async';
import 'dart:developer';
import 'package:conquest/core/services/location_service.dart';
import 'package:conquest/core/services/map_sync_service.dart';
import 'package:conquest/data/models/gps_model.dart';
import 'package:conquest/data/models/map_state.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';

class MapViewModel extends Notifier<MapState> {
  final _locationService = LocationService();
  final _syncService = MapSyncService();

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
      state = state.copyWith(currentPoints: points);
    });

    ref.onDispose(() {
      _pointSubscription?.cancel();
      _connectivitySubscription?.cancel();
      _durationTimer?.cancel();
    });

    Future.microtask(() {
      _loadLog(initialState.selectedDate);
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
      sessionStart: _locationService.sessionStart,
    );

    return true;
  }

  Future<void> stopTracking() async {
    _durationTimer?.cancel();
    _durationTimer = null;

    final session = await _locationService.stopTracking();
    if (session == null) {
      state = state.copyWith(isTracking: false, clearFocusedSession: true);
      return;
    }

    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);
    final existingSessions = state.dayLog?.sessions ?? [];
    final updatedSessions = [...existingSessions, session];
    final updatedLog = GpsLog(date: todayDate, sessions: updatedSessions);

    state = state.copyWith(
      isTracking: false,
      currentPoints: [],
      sessionStart: null,
      dayLog: updatedLog,
      focusedSession: session,
    );

    await _syncService.saveAndSync(updatedLog);
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

  void focusSession(GpsSession session) {
    state = state.copyWith(focusedSession: session);
  }

  void clearFocus() {
    state = state.copyWith(clearFocusedSession: true);
  }

  Future<void> deleteSession(GpsSession session) async {
    final updatedSessions = state.dayLog?.sessions
        .where((s) => s.sessionId != session.sessionId)
        .toList();

    if (updatedSessions == null) return;

    if (updatedSessions.isEmpty) {
      await _syncService.deleteLog(state.selectedDate);
      state = state.copyWith(clearDayLog: true, clearFocusedSession: true);
    } else {
      final updatedLog = GpsLog(
        date: state.selectedDate,
        sessions: updatedSessions,
      );
      await _syncService.saveAndSync(updatedLog);
      state = state.copyWith(dayLog: updatedLog, clearFocusedSession: true);
    }

    await _syncService.deleteSession(state.selectedDate, session.sessionId);
  }

  Future<void> refresh() async {
    await _loadLog(state.selectedDate);
  }
}

final mapProvider = NotifierProvider<MapViewModel, MapState>(MapViewModel.new);
