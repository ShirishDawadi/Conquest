import 'package:conquest/core/constants/date_constants.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class DatePicker extends StatelessWidget {
  final int month;
  final int year;
  final DateTime today;
  final ValueChanged<int> onMonthChanged;
  final ValueChanged<int> onYearChanged;
  final VoidCallback onDismiss;

  const DatePicker({
    super.key,
    required this.month,
    required this.year,
    required this.today,
    required this.onMonthChanged,
    required this.onYearChanged,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    final textColor = Theme.of(context).colorScheme.onSurface;

    return Stack(
      children: [
        Positioned.fill(
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: onDismiss,
            child: const SizedBox.expand(),
          ),
        ),

        Row(
          children: [
            Expanded(
              child: CupertinoPicker(
                itemExtent: 28,
                selectionOverlay: const SizedBox(),
                scrollController: FixedExtentScrollController(
                  initialItem: month,
                ),
                onSelectedItemChanged: onMonthChanged,
                children: DateConstants.months
                    .map(
                      (m) => Center(
                        child: Text(
                          m,
                          style: TextStyle(fontSize: 14, color: textColor),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
            Expanded(
              child: CupertinoPicker(
                itemExtent: 28,
                selectionOverlay: const SizedBox(),
                scrollController: FixedExtentScrollController(
                  initialItem: year - 2024,
                ),
                onSelectedItemChanged: onYearChanged,
                children: List.generate(
                  today.year - 2023,
                  (i) => Center(
                    child: Text(
                      '${2024 + i}',
                      style: TextStyle(fontSize: 14, color: textColor),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}