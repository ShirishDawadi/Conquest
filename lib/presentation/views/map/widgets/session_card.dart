import 'package:conquest/core/utils/tracking_utils.dart';
import 'package:conquest/data/models/gps_model.dart';
import 'package:conquest/presentation/viewmodels/map_viewmodel.dart';
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
      borderRadius: 10,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(6,6,6,12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => onExpand(),
                  child: SvgPicture.asset(
                    'assets/icons/expand.svg',
                    width: 20,
                    height: 20,
                  ),
                ),
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => ref.read(mapProvider.notifier).clearFocus(),
                  child: SvgPicture.asset(
                    'assets/icons/cross.svg',
                    width: 20,
                    height: 20,
                  ),
                ),
                  
              ],
            ),
            Text(
              '$pace km/hr',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            SvgPicture.asset('assets/icons/distance.svg', width: 20),
            Text('$distStr km', style: const TextStyle(fontSize: 10)),
            const SizedBox(height: 8),
            SvgPicture.asset('assets/icons/time.svg', width: 20),
            Text(durStr, style: const TextStyle(fontSize: 10)),
          ],
        ),
      ),
    );
  }
}
