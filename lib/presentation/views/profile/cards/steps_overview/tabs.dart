import 'package:flutter/material.dart';

enum StatsPeriod { weekly, monthly }

class WeeklyMonthlyToggle extends StatelessWidget {
  final StatsPeriod selected;
  final ValueChanged<StatsPeriod> onChanged;

  const WeeklyMonthlyToggle({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  static const double _borderWidth = 1.0;
  static const double _height = 26.0;
  static const double _overlap = 1.0;

  @override
  Widget build(BuildContext context) {
    final options = [StatsPeriod.weekly, StatsPeriod.monthly];
    final labels = ['Weekly', 'Monthly'];
    final selectedIndex = options.indexOf(selected);

    return Container(
      width: 160,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.03),
        border: Border.all(
          width: _borderWidth,
          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.10),
        ),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final segmentWidth = constraints.maxWidth / options.length;
          final isFirst = selectedIndex == 0;
          final isLast = selectedIndex == options.length - 1;

          return Stack(
            clipBehavior: Clip.none,
            children: [
              AnimatedPositioned(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                left: selectedIndex * segmentWidth - (isFirst ? _overlap : 0),
                top: -_overlap,
                bottom: -_overlap,
                width: segmentWidth + (isFirst || isLast ? _overlap : 0),
                child: Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
              Row(
                children: List.generate(options.length, (i) {
                  final isSelected = options[i] == selected;
                  return GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => onChanged(options[i]),
                    child: SizedBox(
                      width: segmentWidth,
                      height: _height,
                      child: Center(
                        child: Text(
                          labels[i],
                          style: TextStyle(
                            fontWeight:
                                isSelected ? FontWeight.w600 : FontWeight.normal,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ],
          );
        },
      ),
    );
  }
}