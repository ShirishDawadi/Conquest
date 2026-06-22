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

  static List<GpsPoint> rdp(List<GpsPoint> points, {double epsilon = 0.0001}) {
    if (points.length < 3) return points;

    final start = points.first;
    final end = points.last;
    final sameEndpoints = start.lat == end.lat && start.lng == end.lng;

    double perpendicularDistance(GpsPoint p, GpsPoint p1, GpsPoint p2) {
      if (sameEndpoints) {
        final dx = p.lng - p1.lng;
        final dy = p.lat - p1.lat;
        return (dx * dx + dy * dy);
      }

      // cross product magnitude: |(P2 - P1) × (P1 - P0)|
      final dx = p2.lng - p1.lng;
      final dy = p2.lat - p1.lat;
      final lineLength = (dx * dx + dy * dy);

      if (lineLength == 0) return 0;

      final cross = ((p.lng - p1.lng) * dy - (p.lat - p1.lat) * dx).abs();
      return cross / lineLength; // normalized perpendicular distance
    }

    double maxDist = 0;
    int maxIndex = 0;

    for (int i = 1; i < points.length - 1; i++) {
      final d = perpendicularDistance(points[i], start, end);
      if (d > maxDist) {
        maxDist = d;
        maxIndex = i;
      }
    }

    if (maxDist > epsilon) {
      final left = rdp(points.sublist(0, maxIndex + 1), epsilon: epsilon);
      final right = rdp(points.sublist(maxIndex), epsilon: epsilon);
      return [...left.sublist(0, left.length - 1), ...right];
    }

    return [start, end];
  }
}
