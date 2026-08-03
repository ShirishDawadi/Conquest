import 'dart:async';
import 'package:conquest/core/utils/tracking_utils.dart';
import 'package:conquest/presentation/viewmodels/map_viewmodel.dart';
import 'package:conquest/presentation/views/shared_widgets/glass_container.dart';
import 'package:conquest/presentation/views/shared_widgets/session_distance_radius.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';

class TrackingBar extends ConsumerStatefulWidget {
  const TrackingBar({super.key});

  @override
  ConsumerState<TrackingBar> createState() => _TrackingBarState();
}

class _TrackingBarState extends ConsumerState<TrackingBar> {
  Timer? _timer;
  bool _dotVisible = true;
  Duration _elapsed = Duration.zero;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(milliseconds: 600), (_) {
      if (mounted) setState(() => _dotVisible = !_dotVisible);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mapState = ref.watch(mapProvider);
    final distanceMeters = ref.watch(liveSessionDistanceMetersProvider);
    final distanceKm = distanceMeters / 1000;

    if (mapState.sessionStart != null) {
      _elapsed = DateTime.now().difference(mapState.sessionStart!);
    }

    final distanceStr = distanceKm.toStringAsFixed(2);
    final pace = TrackingUtils.speedString(mapState.currentPoints, _elapsed);
    final durationStr = TrackingUtils.formatDuration(_elapsed);

    return GlassContainer(
      borderRadius: 40,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          children: [
            AnimatedOpacity(
              opacity: _dotVisible ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 300),
              child: Container(
                width: 10,
                height: 10,
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
              ),
            ),
            const SizedBox(width: 10),

            Text(
              '${pace}km/hr',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(width: 15),

            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SvgPicture.asset(
                  'assets/icons/steps.svg',
                  width: 20,
                  colorFilter: ColorFilter.mode(
                    Theme.of(context).iconTheme.color!,
                    BlendMode.srcIn,
                  ),
                ),
                const SizedBox(width: 4),
                Text('${distanceStr}km', style: TextStyle(fontSize: 12)),
              ],
            ),
            const SizedBox(width: 15),

            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SvgPicture.asset(
                  'assets/icons/time.svg',
                  width: 20,
                  colorFilter: ColorFilter.mode(
                    Theme.of(context).iconTheme.color!,
                    BlendMode.srcIn,
                  ),
                ),
                const SizedBox(width: 4),
                Text(durationStr, style: TextStyle(fontSize: 12)),
              ],
            ),

            const Spacer(),

            SessionDistanceRadius(distanceMeters: distanceMeters, size: 24),
          ],
        ),
      ),
    );
  }
}
