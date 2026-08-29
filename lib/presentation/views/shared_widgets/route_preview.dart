// presentation/views/shared_widgets/route_preview.dart
//
// Small static route thumbnail from a GpsSession's points. No map tiles,
// no flutter_map dependency — just normalizes lat/lng into local pixel
// space and draws a path. Cheap enough to use in a list row.

import 'package:conquest/data/models/gps_model.dart';
import 'package:flutter/material.dart';

class RoutePreview extends StatelessWidget {
  final GpsSession session;
  final double size;
  final Color color;
  final double strokeWidth;

  const RoutePreview({
    super.key,
    required this.session,
    this.size = 22,
    this.color = Colors.green,
    this.strokeWidth = 1.6,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _RoutePreviewPainter(
          points: session.points,
          color: color,
          strokeWidth: strokeWidth,
        ),
      ),
    );
  }
}

class _RoutePreviewPainter extends CustomPainter {
  final List<GpsPoint> points;
  final Color color;
  final double strokeWidth;

  _RoutePreviewPainter({
    required this.points,
    required this.color,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (points.isEmpty) return;

    // Single point (or a near-zero-distance session) -> draw a dot instead
    // of a degenerate/invisible line.
    if (points.length == 1) {
      final center = Offset(size.width / 2, size.height / 2);
      canvas.drawCircle(center, strokeWidth * 1.5, Paint()..color = color);
      return;
    }

    double minLat = points.first.lat, maxLat = points.first.lat;
    double minLng = points.first.lng, maxLng = points.first.lng;
    for (final p in points) {
      if (p.lat < minLat) minLat = p.lat;
      if (p.lat > maxLat) maxLat = p.lat;
      if (p.lng < minLng) minLng = p.lng;
      if (p.lng > maxLng) maxLng = p.lng;
    }

    final latSpan = (maxLat - minLat).abs();
    final lngSpan = (maxLng - minLng).abs();

    // Degenerate bounding box (e.g. GPS jitter session with ~0 movement) ->
    // also just draw a dot rather than a stretched/garbage line.
    if (latSpan < 1e-7 && lngSpan < 1e-7) {
      final center = Offset(size.width / 2, size.height / 2);
      canvas.drawCircle(center, strokeWidth * 1.5, Paint()..color = color);
      return;
    }

    // Leave a small margin so the line doesn't touch the edges.
    const margin = 3.0;
    final drawableW = size.width - margin * 2;
    final drawableH = size.height - margin * 2;

    // Keep aspect ratio: scale by whichever span is more constraining, then
    // center the smaller axis. Avoids stretching narrow/tall routes.
    final scale = latSpan == 0 || lngSpan == 0
        ? 1.0
        : (drawableW / lngSpan < drawableH / latSpan
            ? drawableW / lngSpan
            : drawableH / latSpan);

    final scaledW = lngSpan * scale;
    final scaledH = latSpan * scale;
    final offsetX = margin + (drawableW - scaledW) / 2;
    final offsetY = margin + (drawableH - scaledH) / 2;

    Offset toOffset(GpsPoint p) {
      final x = lngSpan == 0
          ? drawableW / 2 + margin
          : offsetX + (p.lng - minLng) * scale;
      // Flip Y: latitude increases upward, canvas Y increases downward.
      final y = latSpan == 0
          ? drawableH / 2 + margin
          : offsetY + (maxLat - p.lat) * scale;
      return Offset(x, y);
    }

    final path = Path()..moveTo(toOffset(points.first).dx, toOffset(points.first).dy);
    for (final p in points.skip(1)) {
      final o = toOffset(p);
      path.lineTo(o.dx, o.dy);
    }

    canvas.drawPath(
      path,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );
  }

  @override
  bool shouldRepaint(covariant _RoutePreviewPainter oldDelegate) {
    return oldDelegate.points != points ||
        oldDelegate.color != color ||
        oldDelegate.strokeWidth != strokeWidth;
  }
}