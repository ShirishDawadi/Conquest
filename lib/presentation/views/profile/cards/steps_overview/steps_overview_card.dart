import 'package:conquest/data/models/activity_model.dart';
import 'package:conquest/presentation/viewmodels/steps_stats_viewmodel.dart';
import 'package:conquest/presentation/views/profile/cards/steps_overview/days_stat.dart';
import 'package:conquest/presentation/views/profile/cards/steps_overview/steps_bar_chart.dart';
import 'package:conquest/presentation/views/profile/cards/steps_overview/steps_summary.dart';
import 'package:conquest/presentation/views/profile/cards/steps_overview/tabs.dart';
import 'package:conquest/presentation/views/shared_widgets/glass_container.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class StepsOverviewCard extends ConsumerStatefulWidget {
  const StepsOverviewCard({super.key});

  @override
  ConsumerState<StepsOverviewCard> createState() => _StepsOverviewCardState();
}

class _StepsOverviewCardState extends ConsumerState<StepsOverviewCard> {
  StatsPeriod _period = StatsPeriod.weekly;
  StepsStatsDay? _selectedDay;

  String _rangeLabel(DateTime start, DateTime end) {
    final sameYear = start.year == end.year;
    final startFmt = DateFormat(sameYear ? 'd MMM' : 'd MMM yyyy');
    final endFmt = DateFormat('d MMM yyyy');
    return '${startFmt.format(start)} - ${endFmt.format(end)}';
  }

  /// Picks which day to show when nothing's explicitly tapped:
  /// - if today falls inside the visible range (current week/month), show today
  /// - otherwise (viewing a past week/month), show the most recent day in
  ///   that range instead of defaulting to "today" (which isn't in range).
  StepsStatsDay _defaultDay(
    List<StepsStatsDay> days,
    DateTime rangeStart,
    DateTime rangeEnd,
  ) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final todayInRange =
        !today.isBefore(rangeStart) && !today.isAfter(rangeEnd);

    if (todayInRange) {
      final todayIso = today.toIso8601String().substring(0, 10);
      return days.firstWhere(
        (d) => d.date == todayIso,
        orElse: () => StepsStatsDay(date: todayIso, steps: 0, goal: 0),
      );
    }

    if (days.isEmpty) {
      return StepsStatsDay(
        date: rangeEnd.toIso8601String().substring(0, 10),
        steps: 0,
        goal: 0,
      );
    }

    // Past range -> most recent day actually in that period (days is
    // assumed ordered ascending by date, same as the bar chart expects).
    return days.last;
  }

  @override
  Widget build(BuildContext context) {
    final statsState = ref.watch(stepsStatsProvider);
    final isLoading = ref.watch(stepsStatsLoadingProvider);
    final notifier = ref.read(stepsStatsProvider.notifier);
    final days = statsState.value?.days ?? [];
    final range = notifier.currentRange;
    final displayDay =
        _selectedDay ?? _defaultDay(days, range.start, range.end);

    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: GlassContainer(
        blur: 0,
        child: Container(
          padding: const EdgeInsets.all(16),
          width: double.infinity,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                "Steps Overview",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Gpkn',
                ),
              ),
              const SizedBox(height: 10),
              WeeklyMonthlyToggle(
                selected: _period,
                onChanged: (p) {
                  setState(() {
                    _period = p;
                    _selectedDay = null;
                  });
                  notifier.load(p);
                },
              ),
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  _rangeLabel(range.start, range.end),
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.50),
                  ),
                ),
              ),
              const SizedBox(height: 6),
              StepsBarChart(
                days: days,
                isLoading: isLoading,
                onBarTap: (day) => setState(() => _selectedDay = day),
                onSwipeLeft: notifier.canGoNext
                    ? () {
                        setState(() => _selectedDay = null);
                        notifier.next();
                      }
                    : null,
                onSwipeRight: () {
                  setState(() => _selectedDay = null);
                  notifier.previous();
                },
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  DaysStat(day: displayDay),
                  const SizedBox(width: 5),
                  Expanded(
                    child: StepsSummaryRow(
                      stats:
                          statsState.value ??
                          StepsStatsResponse(
                            days: const [],
                            averageSteps: 0,
                            totalSteps: 0,
                          ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}