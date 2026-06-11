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
  final int sessionId;
  final DateTime startedAt;
  final DateTime? endedAt;
  final List<GpsPoint> points;

  const GpsSession({
    required this.sessionId,
    required this.startedAt,
    this.endedAt,
    required this.points,
  });

  double get distanceKm {
    if (points.length < 2) return 0.0;
    const distance = Distance();
    double total = 0.0;
    for (int i = 0; i < points.length - 1; i++) {
      total += distance(points[i].toLatLng(), points[i + 1].toLatLng());
    }
    return total / 1000;
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
    'session_id': sessionId,
    'started_at': startedAt.toIso8601String(),
    'ended_at': endedAt?.toIso8601String(),
    'points': points.map((p) => p.toJson()).toList(),
  };

  factory GpsSession.fromJson(Map<String, dynamic> json) => GpsSession(
    sessionId: json['session_id'] as int,
    startedAt: DateTime.parse(json['started_at'] as String),
    endedAt: json['ended_at'] != null
        ? DateTime.parse(json['ended_at'] as String)
        : null,
    points: (json['points'] as List)
        .map((p) => GpsPoint.fromJson(p as Map<String, dynamic>))
        .toList(),
  );
}

class GpsLog {
  final DateTime date;
  final List<GpsSession> sessions;

  const GpsLog({required this.date, required this.sessions});

  Map<String, dynamic> toJson() => {
    'date': date.toIso8601String().substring(0, 10),
    'path': sessions.map((s) => s.toJson()).toList(),
  };

  factory GpsLog.fromJson(Map<String, dynamic> json) => GpsLog(
    date: DateTime.parse(json['date'] as String),
    sessions: (json['path'] as List)
        .map((s) => GpsSession.fromJson(s as Map<String, dynamic>))
        .toList(),
  );
}
