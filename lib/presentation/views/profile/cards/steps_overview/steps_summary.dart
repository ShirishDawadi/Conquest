import 'package:conquest/core/theme/app_colors.dart';
import 'package:conquest/data/models/activity_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

int stepsToKcal(int steps) => (steps * 0.04).round();

class StepsSummaryRow extends StatelessWidget {
  final StepsStatsResponse stats;

  const StepsSummaryRow({super.key, required this.stats});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border.all(
          color: Theme.of(
            context,
          ).colorScheme.onSurface.withValues(alpha: 0.10),
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Expanded(
            child: _StepsSummaryStat(
              label: 'Average',
              steps: stats.averageSteps,
            ),
          ),
          Container(
            width: 1,
            height: 48,
            color: Theme.of(
              context,
            ).colorScheme.onSurface.withValues(alpha: 0.10),
          ),
          Expanded(
            child: _StepsSummaryStat(label: 'Total', steps: stats.totalSteps),
          ),
        ],
      ),
    );
  }
}

class _StepsSummaryStat extends StatelessWidget {
  final String label;
  final int steps;

  const _StepsSummaryStat({required this.label, required this.steps});

  @override
  Widget build(BuildContext context) {
    final mutedColor = Theme.of(
      context,
    ).colorScheme.onSurface.withValues(alpha: 0.50);

    return Column(
      children: [
        Text(label, style: TextStyle(fontSize: 10, color: mutedColor)),
        const SizedBox(height: 6),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(
              'assets/icons/steps.svg',
              width: 16,
              height: 16,
              colorFilter: const ColorFilter.mode(
                AppColors.greenish_3,
                BlendMode.srcIn,
              ),
            ),
            const SizedBox(width: 6),
            TweenAnimationBuilder<int>(
              tween: IntTween(end: steps),
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeOutCubic,
              builder: (context, value, _) => Text(
                '$value steps',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset('assets/icons/kcal.svg', width: 16, height: 16),
            const SizedBox(width: 6),
            TweenAnimationBuilder<int>(
              tween: IntTween(end: stepsToKcal(steps)),
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeOutCubic,
              builder: (context, value, _) =>
                  Text('$value kcal', style: TextStyle(fontSize: 12)),
            ),
          ],
        ),
      ],
    );
  }
}
