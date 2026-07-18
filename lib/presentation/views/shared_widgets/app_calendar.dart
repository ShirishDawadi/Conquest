import 'package:conquest/core/constants/date_constants.dart';
import 'package:conquest/core/theme/app_colors.dart';
import 'package:conquest/presentation/views/shared_widgets/date_picker.dart';
import 'package:conquest/presentation/views/shared_widgets/glass_container.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class AppCalendar extends StatefulWidget {
  final DateTime selectedDate;
  final ValueChanged<DateTime> onDateSelected;

  const AppCalendar({
    super.key,
    required this.selectedDate,
    required this.onDateSelected,
  });

  @override
  State<AppCalendar> createState() => _AppCalendarState();
}

class _AppCalendarState extends State<AppCalendar> {
  late int _month;
  late int _year;

  bool _showPicker = false;
  final today = DateTime.now();

  static const _weekdays = ['Su', 'Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa'];
  static const _totalCells = 42;

  @override
  void initState() {
    super.initState();
    _month = widget.selectedDate.month - 1;
    _year = widget.selectedDate.year;
  }

  bool _isFuture(DateTime date) {
    final todayDate = DateTime(today.year, today.month, today.day);
    return date.isAfter(todayDate);
  }

  bool _isSelected(DateTime date) {
    return date.year == widget.selectedDate.year &&
        date.month == widget.selectedDate.month &&
        date.day == widget.selectedDate.day;
  }

  void _prevMonth() {
    setState(() {
      if (_month == 0) {
        _month = 11;
        _year--;
      } else {
        _month--;
      }
    });
  }

  void _nextMonth() {
    final next = DateTime(_year, _month + 2, 1);
    final todayDate = DateTime(today.year, today.month, today.day);
    if (next.isAfter(todayDate)) return;
    setState(() {
      if (_month == 11) {
        _month = 0;
        _year++;
      } else {
        _month++;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final firstDay = DateTime(_year, _month + 1, 1).weekday % 7;
    final daysInMonth = DateUtils.getDaysInMonth(_year, _month + 1);

    return Stack(
      children: [
        GlassContainer(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: _prevMonth,
                        child: SvgPicture.asset(
                          'assets/icons/nav_left.svg',
                          width: 20,
                          colorFilter: ColorFilter.mode(
                            Theme.of(context).colorScheme.onSurface,
                            BlendMode.srcIn,
                          ),
                        ),
                      ),

                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _showPicker = !_showPicker;
                          });
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            vertical: 2,
                            horizontal: 4,
                          ),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey, width: 0.5),
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '${DateConstants.monthsShort[_month]}, $_year',
                                style: const TextStyle(fontSize: 12),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(width: 2.5),
                              const Icon(Icons.arrow_drop_down, size: 16),
                            ],
                          ),
                        ),
                      ),

                      GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: _nextMonth,
                        child: SvgPicture.asset(
                          'assets/icons/nav_right.svg',
                          width: 20,
                          colorFilter: ColorFilter.mode(
                            Theme.of(context).colorScheme.onSurface,
                            BlendMode.srcIn,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 0),

                Row(
                  children: _weekdays
                      .map(
                        (d) => Expanded(
                          child: Text(
                            d,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 10,
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurface.withValues(alpha: 0.5),
                            ),
                          ),
                        ),
                      )
                      .toList(),
                ),

                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: EdgeInsets.zero,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 7,
                    childAspectRatio: 1,
                  ),
                  itemCount: _totalCells,
                  itemBuilder: (context, index) {
                    late final DateTime date;
                    late final bool inCurrentMonth;

                    if (index < firstDay) {
                      final prevMonthDate = DateTime(_year, _month + 1, 0);
                      final day = prevMonthDate.day - (firstDay - index - 1);
                      date = DateTime(
                        prevMonthDate.year,
                        prevMonthDate.month,
                        day,
                      );
                      inCurrentMonth = false;
                    } else if (index < firstDay + daysInMonth) {
                      final day = index - firstDay + 1;
                      date = DateTime(_year, _month + 1, day);
                      inCurrentMonth = true;
                    } else {
                      final day = index - firstDay - daysInMonth + 1;
                      final nextMonthDate = DateTime(_year, _month + 2, 1);
                      date = DateTime(
                        nextMonthDate.year,
                        nextMonthDate.month,
                        day,
                      );
                      inCurrentMonth = false;
                    }

                    final isFuture = _isFuture(date);
                    final isSelected = inCurrentMonth && _isSelected(date);
                    final isMuted = !inCurrentMonth || isFuture;

                    return GestureDetector(
                      onTap: (!inCurrentMonth || isFuture)
                          ? null
                          : () => widget.onDateSelected(date),
                      child: Container(
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.greenish_3
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Center(
                          child: Text(
                            '${date.day}',
                            style: TextStyle(
                              fontSize: 12,
                              color: isSelected
                                  ? Colors.white
                                  : isMuted
                                  ? Theme.of(context).colorScheme.onSurface
                                        .withValues(alpha: 0.3)
                                  : Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),

        if (_showPicker) ...[
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                setState(() => _showPicker = false);
              },
              child: const SizedBox.expand(),
            ),
          ),

          Align(
            alignment: Alignment.topCenter,
            child: Padding(
              padding: const EdgeInsets.only(top: 40),
              child: GlassContainer(
                borderRadius: 15,
                blur: 7,
                child: SizedBox(
                  width: 150,
                  height: 100,
                  child: DatePicker(
                    month: _month,
                    year: _year,
                    today: today,
                    onDismiss: () {
                      setState(() => _showPicker = false);
                    },
                    onMonthChanged: (index) {
                      setState(() => _month = index);
                    },
                    onYearChanged: (index) {
                      setState(() => _year = 2024 + index);
                    },
                  ),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}
