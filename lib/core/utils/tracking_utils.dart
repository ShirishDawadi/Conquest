import 'dart:math';
import 'package:conquest/data/models/gps_model.dart';
import 'package:latlong2/latlong.dart';

class TrackingUtils {
  static double distanceKm(List<GpsPoint> points) {
    if (points.length < 2) return 0.0;
    const distance = Distance();
    double total = 0.0;
    for (int i = 0; i < points.length - 1; i++) {
      total += distance(points[i].toLatLng(), points[i + 1].toLatLng());
    }
    return total / 1000;
  }

  static String speedString(List<GpsPoint> points, Duration duration) {
    if (duration.inSeconds == 0) return '0.0';
    final km = distanceKm(points);
    final hours = duration.inSeconds / 3600;
    return (km / hours).toStringAsFixed(1);
  }

  static bool isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  static bool isFuture(DateTime date) {
    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);
    return date.isAfter(todayDate);
  }

  static String formatDuration(Duration duration) {
    final h = duration.inHours;
    final m = duration.inMinutes.remainder(60);
    final s = duration.inSeconds.remainder(60);
    return '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  static List<GpsPoint> rdp(List<GpsPoint> points, {double epsilon = 3}) {
    if (points.length < 3) return points;

    final origin = points.first;

    final meterPoints = points.map((p) {
      final x = (p.lng - origin.lng) * 111320 * cos(origin.lat * pi / 180);
      final y = (p.lat - origin.lat) * 111320;
      return (x, y);
    }).toList();

    return _rdpRecursive(points, meterPoints, epsilon);
  }

  static List<GpsPoint> _rdpRecursive(
    List<GpsPoint> original,
    List<(double, double)> meterPoints,
    double epsilon,
  ) {
    if (original.length < 3) return original;

    final start = meterPoints.first;
    final end = meterPoints.last;

    double maxDist = 0;
    int maxIndex = 0;

    for (int i = 1; i < meterPoints.length - 1; i++) {
      final d = _perpendicularDistance(meterPoints[i], start, end);
      if (d > maxDist) {
        maxDist = d;
        maxIndex = i;
      }
    }

    if (maxDist > epsilon) {
      final left = _rdpRecursive(
        original.sublist(0, maxIndex + 1),
        meterPoints.sublist(0, maxIndex + 1),
        epsilon,
      );
      final right = _rdpRecursive(
        original.sublist(maxIndex),
        meterPoints.sublist(maxIndex),
        epsilon,
      );
      return [...left.sublist(0, left.length - 1), ...right];
    }

    return [original.first, original.last];
  }

  static double _perpendicularDistance(
    (double, double) p,
    (double, double) p1,
    (double, double) p2,
  ) {
    final dx = p2.$1 - p1.$1;
    final dy = p2.$2 - p1.$2;

    final lineLength = sqrt(dx * dx + dy * dy);

    if (lineLength == 0) {
      return sqrt(
        (p.$1 - p1.$1) * (p.$1 - p1.$1) + (p.$2 - p1.$2) * (p.$2 - p1.$2),
      );
    }

    final cross = ((p.$1 - p1.$1) * dy - (p.$2 - p1.$2) * dx).abs();
    return cross / lineLength;
  }
}