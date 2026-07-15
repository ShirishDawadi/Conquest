import 'package:conquest/presentation/views/profile/cards/steps_overview/tabs.dart';
import 'package:conquest/presentation/views/shared_widgets/glass_container.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class StepsOverviewCard extends ConsumerStatefulWidget {
  const StepsOverviewCard({super.key});

  @override
  ConsumerState<StepsOverviewCard> createState() => _StepsOverviewCardState();
}

class _StepsOverviewCardState extends ConsumerState<StepsOverviewCard> {
  StatsPeriod _period = StatsPeriod.monthly;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: GlassContainer(
        blur: 0,
        child: Container(
          padding: EdgeInsets.all(16),
          width: double.infinity,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                "Steps Overview",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Gpkn',
                ),
              ),
              const SizedBox(height: 10,),
              WeeklyMonthlyToggle(
                selected: _period,
                onChanged: (p) => setState(() => _period = p),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
