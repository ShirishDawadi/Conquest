import 'package:conquest/core/utils/tracking_utils.dart';
import 'package:conquest/data/models/gps_model.dart';
import 'package:conquest/presentation/views/shared_widgets/glass_container.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';

class SessionCard extends ConsumerWidget {
  final GpsSession session;
  final VoidCallback onExpand;

  const SessionCard({super.key, required this.session, required this.onExpand});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final distStr = session.distanceKm.toStringAsFixed(2);
    final durStr = TrackingUtils.formatDuration(session.duration);
    final pace = session.speedString;

    return GlassContainer(
      child: Container(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => onExpand(),
              child: Align(
                alignment: AlignmentGeometry.centerLeft,
                child: SvgPicture.asset(
                  'assets/icons/expand.svg',
                  width: 16,
                  height: 16,
                ),
              ),
            ),
            Text(
              '$pace km/hr',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 6),
            SvgPicture.asset('assets/icons/steps.svg', width: 20),
            const SizedBox(height: 4),
            Text('$distStr km', style: const TextStyle(fontSize: 10)),
            const SizedBox(height: 8),
            SvgPicture.asset('assets/icons/time.svg', width: 20),
            const SizedBox(height: 4),
            Text(durStr, style: const TextStyle(fontSize: 10)),
          ],
        ),
      ),
    );
  }
}
