import 'package:conquest/data/models/activity_model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DaysStat extends StatelessWidget {
  final StepsStatsDay day;

  const DaysStat({super.key, required this.day});

  @override
  Widget build(BuildContext context) {
    final formattedDate = DateFormat(
      'd MMM y',
    ).format(DateTime.parse(day.date));

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
      child: Column(
        children: [
          Text(
            formattedDate,
            style: TextStyle(
              fontSize: 10,
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.50),
            ),
          ),
          const SizedBox(height: 6),
          Container(
            height: 16,
            constraints: const BoxConstraints(minWidth: 64),
            child: TweenAnimationBuilder<int>(
              tween: IntTween(end: day.steps),
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeOutCubic,
              builder: (context, value, _) => Text(
                '$value steps',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(height: 2),
          Container(
            height: 16,
            constraints: const BoxConstraints(minWidth: 64),
            child: TweenAnimationBuilder<int>(
              tween: IntTween(end: day.goal),
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeOutCubic,
              builder: (context, value, _) => Text(
                '$value goal',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
