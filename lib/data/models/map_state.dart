import 'package:conquest/data/models/gps_model.dart';

enum LocationPermissionStatus { unknown, granted, denied, serviceDisabled }

class MapState {
  final bool isTracking;
  final List<GpsPoint> currentPoints;
  final DateTime? sessionStart;
  final GpsLog? dayLog;
  final DateTime selectedDate;
  final GpsSession? focusedSession;
  final bool isLoading;
  final String? error;
  final LocationPermissionStatus permissionStatus;

  const MapState({
    this.isTracking = false,
    this.currentPoints = const [],
    this.sessionStart,
    this.dayLog,
    required this.selectedDate,
    this.focusedSession,
    this.isLoading = false,
    this.error,
    this.permissionStatus = LocationPermissionStatus.unknown,
  });

  MapState copyWith({
    bool? isTracking,
    List<GpsPoint>? currentPoints,
    DateTime? sessionStart,
    GpsLog? dayLog,
    bool clearDayLog = false,
    DateTime? selectedDate,
    GpsSession? focusedSession,
    bool clearFocusedSession = false,
    bool? isLoading,
    String? error,
    bool clearError = false,
    LocationPermissionStatus? permissionStatus,
  }) {
    return MapState(
      isTracking: isTracking ?? this.isTracking,
      currentPoints: currentPoints ?? this.currentPoints,
      sessionStart: sessionStart ?? this.sessionStart,
      dayLog: clearDayLog ? null : dayLog ?? this.dayLog,
      selectedDate: selectedDate ?? this.selectedDate,
      focusedSession:
          clearFocusedSession ? null : focusedSession ?? this.focusedSession,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : error ?? this.error,
      permissionStatus: permissionStatus ?? this.permissionStatus,
    );
  }
}