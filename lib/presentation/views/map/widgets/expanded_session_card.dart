import 'package:conquest/core/theme/app_colors.dart';
import 'package:conquest/core/utils/tracking_utils.dart';
import 'package:conquest/data/models/gps_model.dart';
import 'package:conquest/presentation/viewmodels/map_viewmodel.dart';
import 'package:conquest/presentation/views/shared_widgets/glass_container.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';

class ExpandedCard extends ConsumerWidget {
  final GpsSession session;
  final VoidCallback onCollapse;

  const ExpandedCard({
    super.key,
    required this.session,
    required this.onCollapse,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final distStr = session.distanceKm.toStringAsFixed(2);
    final durStr = TrackingUtils.formatDuration(session.duration);
    final pace = session.speedString;
    final startTime = _formatTime(session.startedAt);
    final endTime = session.endedAt != null
        ? _formatTime(session.endedAt!)
        : '--:--';
    final dateStr = _formatDate(session.startedAt);

    return GlassContainer(
      child: Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: onCollapse,
                  child: SvgPicture.asset(
                    'assets/icons/collapse.svg',
                    width: 24,
                    height: 24,
                  ),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: () {
                    ref.read(mapProvider.notifier).deleteSession(session);
                  },
                  behavior: HitTestBehavior.opaque,
                  child: SvgPicture.asset(
                    'assets/icons/delete.svg',
                    width: 24,
                    height: 24,
                  ),
                ),
                const SizedBox(width: 12),
                GestureDetector(
                  onTap: () {},
                  behavior: HitTestBehavior.opaque,
                  child: SvgPicture.asset(
                    'assets/icons/share.svg',
                    width: 24,
                    height: 24,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            _RouteDiagram(session: session),
            const SizedBox(height: 12),

            Text(
              '$pace km/hr',
              style: const TextStyle(fontFamily: 'Gpkn', fontSize: 24),
            ),
            const SizedBox(height: 12),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Column(
                  children: [
                    SvgPicture.asset('assets/icons/steps.svg', width: 30),
                    const SizedBox(height: 4),
                    Text(
                      '$distStr km',
                      style: const TextStyle(fontFamily: 'Gpkn', fontSize: 16),
                    ),
                  ],
                ),

                const SizedBox(width: 24),
                Column(
                  children: [
                    SvgPicture.asset('assets/icons/time.svg', width: 30),
                    const SizedBox(height: 4),
                    Text(
                      durStr,
                      style: const TextStyle(fontFamily: 'Gpkn', fontSize: 16),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),

            Text(
              dateStr,
              style: TextStyle(
                fontSize: 11,
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.5),
              ),
            ),
            Text(
              '$startTime - $endTime',
              style: TextStyle(
                fontSize: 11,
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.5),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime dt) {
    final h = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
    final m = dt.minute.toString().padLeft(2, '0');
    final period = dt.hour < 12 ? 'am' : 'pm';
    return '$h:$m $period';
  }

  String _formatDate(DateTime dt) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return '${months[dt.month - 1]} ${dt.day}, ${dt.year}';
  }
}

class _RouteDiagram extends StatelessWidget {
  final GpsSession session;

  const _RouteDiagram({required this.session});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 120,
      height: 120,
      child: CustomPaint(painter: _RoutePainter(session.latLngs)),
    );
  }
}

class _RoutePainter extends CustomPainter {
  final List<dynamic> points;

  _RoutePainter(this.points);

  @override
  void paint(Canvas canvas, Size size) {
    if (points.length < 2) return;

    double minLat = double.infinity;
    double maxLat = -double.infinity;
    double minLng = double.infinity;
    double maxLng = -double.infinity;

    for (final p in points) {
      if (p.latitude < minLat) minLat = p.latitude;
      if (p.latitude > maxLat) maxLat = p.latitude;
      if (p.longitude < minLng) minLng = p.longitude;
      if (p.longitude > maxLng) maxLng = p.longitude;
    }

    final latRange = (maxLat - minLat).abs();
    final lngRange = (maxLng - minLng).abs();
    final range = latRange > lngRange ? latRange : lngRange;
    if (range == 0) return;

    const padding = 10.0;
    final drawSize = size.width - padding * 2;

    final lngOffset = (range - lngRange) / range * drawSize / 2;
    final latOffset = (range - latRange) / range * drawSize / 2;

    Offset normalize(dynamic p) {
      final x =
          padding + lngOffset + ((p.longitude - minLng) / range) * drawSize;
      final y =
          padding + latOffset + ((maxLat - p.latitude) / range) * drawSize;
      return Offset(x, y);
    }

    final paint = Paint()
      ..color = AppColors.greenish_3
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final path = Path();
    path.moveTo(normalize(points.first).dx, normalize(points.first).dy);
    for (int i = 1; i < points.length; i++) {
      path.lineTo(normalize(points[i]).dx, normalize(points[i]).dy);
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_RoutePainter old) => false;
}
