import 'package:conquest/presentation/viewmodels/map_viewmodel.dart';
import 'package:conquest/presentation/views/home/cards/activity_stats/milestone_ring_group.dart';
import 'package:conquest/presentation/views/home/cards/activity_stats/session_avatar_card.dart';
import 'package:conquest/presentation/views/shared_widgets/glass_container.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ActivityStatsCard extends ConsumerWidget {
  final bool isSessionActive;
  final double? bestSessionKm;

  const ActivityStatsCard({
    super.key,
    required this.isSessionActive,
    required this.bestSessionKm,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final onSurface = Theme.of(context).colorScheme.onSurface;

    final effectiveDistanceKm = isSessionActive
        ? ref.watch(liveSessionDistanceMetersProvider) / 1000
        : 0.0;

    return GlassContainer(
      blur: 0,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Text(
                'Activity Stats',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 4),
            Center(
              child: Text(
                'Walk further from where you started to earn XP',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 10,
                  color: onSurface.withValues(alpha: 0.5),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                ConstrainedBox(
                  constraints: BoxConstraints(minWidth: 120),
                  child: SessionAvatarCard(
                    isSessionActive: isSessionActive,
                    currentDistanceKm: effectiveDistanceKm,
                    bestSessionKm: bestSessionKm,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Center(
                    child: MilestoneRingGroup(
                      distanceMeters: effectiveDistanceKm * 1000,
                      highestMeter: (bestSessionKm ?? 0) * 1000,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              'Note: rewards granted once per day for your best session',
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: 10,
                color: onSurface.withValues(alpha: 0.5),
              ),
            ),
          ],
        ),
      ),
    );
  }
}