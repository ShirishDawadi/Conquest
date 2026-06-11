import 'dart:async';
import 'package:conquest/core/theme/app_colors.dart';
import 'package:conquest/core/utils/tracking_utils.dart';
import 'package:conquest/presentation/viewmodels/map_viewmodel.dart';
import 'package:conquest/presentation/views/shared_widgets/glass_container.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
    final screenWidth = MediaQuery.of(context).size.width;

    if (mapState.sessionStart != null) {
      _elapsed = DateTime.now().difference(mapState.sessionStart!);
    }

    final distanceStr = TrackingUtils.distanceKm(mapState.currentPoints).toStringAsFixed(2);
    final pace = TrackingUtils.speedString(mapState.currentPoints, _elapsed);
    final durationStr = TrackingUtils.formatDuration(_elapsed);

    return GlassContainer(
      borderRadius: 20,
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

            _stat(context, screenWidth, '$pace', 'km/hr'),
            const SizedBox(width: 12),

            _stat(
              context,
              screenWidth,
              distanceStr,
              'km',
              icon: Icons.directions_walk,
            ),
            const SizedBox(width: 12),

            _stat(
              context,
              screenWidth,
              durationStr,
              '',
              icon: Icons.timer_outlined,
            ),

            const Spacer(),

            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.greenish_3, width: 1.5),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.more_horiz,
                size: 18,
                color: AppColors.greenish_3,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _stat(
    BuildContext context,
    double screenWidth,
    String value,
    String unit, {
    IconData? icon,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        if (icon != null) ...[
          Icon(icon, size: screenWidth * 0.035, color: AppColors.greenish_3),
          const SizedBox(width: 4),
        ],
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: screenWidth * 0.035,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (unit.isNotEmpty)
              Text(
                unit,
                style: TextStyle(
                  fontSize: screenWidth * 0.025,
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withValues(alpha: 0.5),
                ),
              ),
          ],
        ),
      ],
    );
  }
}
