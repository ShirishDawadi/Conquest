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
}
