import 'package:latlong2/latlong.dart';

class GpsPoint {
  final double lat;
  final double lng;

  const GpsPoint({required this.lat, required this.lng});

  LatLng toLatLng() => LatLng(lat, lng);

  Map<String, dynamic> toJson() => {'lat': lat, 'lng': lng};

  factory GpsPoint.fromJson(Map<String, dynamic> json) => GpsPoint(
    lat: (json['lat'] as num).toDouble(),
    lng: (json['lng'] as num).toDouble(),
  );
}

class GpsSession {
  final int? localId;
  final int? backendId;
  final DateTime startedAt;
  final DateTime? endedAt;
  final List<GpsPoint> points;
  final double distanceKm;

  const GpsSession({
    this.localId,
    this.backendId,
    required this.startedAt,
    this.endedAt,
    required this.points,
    required this.distanceKm,
  });

  GpsSession copyWith({
    int? localId,
    int? backendId,
    DateTime? startedAt,
    DateTime? endedAt,
    List<GpsPoint>? points,
    double? distanceKm,
  }) {
    return GpsSession(
      localId: localId ?? this.localId,
      backendId: backendId ?? this.backendId,
      startedAt: startedAt ?? this.startedAt,
      endedAt: endedAt ?? this.endedAt,
      points: points ?? this.points,
      distanceKm: distanceKm ?? this.distanceKm,
    );
  }

  Duration get duration {
    if (endedAt == null) return Duration.zero;
    return endedAt!.difference(startedAt);
  }

  String get speedString {
    if (duration.inSeconds == 0) return '0.0';
    final hours = duration.inSeconds / 3600;
    return (distanceKm / hours).toStringAsFixed(1);
  }

  List<LatLng> get latLngs => points.map((p) => p.toLatLng()).toList();

  Map<String, dynamic> toJson() => {
    'started_at': startedAt.toIso8601String(),
    'ended_at': endedAt?.toIso8601String(),
    'points': points.map((p) => p.toJson()).toList(),
    'distance': distanceKm,
  };

  factory GpsSession.fromJson(Map<String, dynamic> json) => GpsSession(
    backendId: json['id'] as int?,
    startedAt: DateTime.parse(json['started_at'] as String),
    endedAt: json['ended_at'] != null
        ? DateTime.parse(json['ended_at'] as String)
        : null,
    points: (json['points'] as List)
        .map((p) => GpsPoint.fromJson(p as Map<String, dynamic>))
        .toList(),
    distanceKm: (json['distance'] as num).toDouble(),
  );
}

class GpsLog {
  final DateTime date;
  final List<GpsSession> sessions;

  const GpsLog({required this.date, required this.sessions});
}
