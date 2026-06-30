import 'package:conquest/core/constants/date_constants.dart';
import 'package:conquest/core/theme/app_colors.dart';
import 'package:conquest/presentation/views/map/widgets/date_picker.dart';
import 'package:conquest/presentation/views/shared_widgets/glass_container.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class MapCalendar extends StatefulWidget {
  final DateTime selectedDate;
  final ValueChanged<DateTime> onDateSelected;

  const MapCalendar({
    super.key,
    required this.selectedDate,
    required this.onDateSelected,
  });

  @override
  State<MapCalendar> createState() => _MapCalendarState();
}

class _MapCalendarState extends State<MapCalendar> {
  late int _month;
  late int _year;

  bool _showPicker = false;
  final today = DateTime.now();

  static const _weekdays = ['Su', 'Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa'];
  
  @override
  void initState() {
    super.initState();
    _month = widget.selectedDate.month - 1;
    _year = widget.selectedDate.year;
  }

  bool _isFuture(int day) {
    final date = DateTime(_year, _month + 1, day);
    final todayDate = DateTime(today.year, today.month, today.day);
    return date.isAfter(todayDate);
  }

  bool _isSelected(int day) {
    return _year == widget.selectedDate.year &&
        _month + 1 == widget.selectedDate.month &&
        day == widget.selectedDate.day;
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
                              SizedBox(
                                width: 90,
                                child: Text(
                                  '${DateConstants.months[_month]}, $_year',
                                  style: const TextStyle(fontSize: 12),
                                  textAlign: TextAlign.center,
                                ),
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
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 4),

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
                  itemCount: firstDay + daysInMonth,
                  itemBuilder: (context, index) {
                    if (index < firstDay) return const SizedBox.shrink();
                    final day = index - firstDay + 1;
                    final isFuture = _isFuture(day);
                    final isSelected = _isSelected(day);

                    return GestureDetector(
                      onTap: isFuture
                          ? null
                          : () {
                              widget.onDateSelected(
                                DateTime(_year, _month + 1, day),
                              );
                            },
                      child: Container(
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.greenish_3
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Center(
                          child: Text(
                            '$day',
                            style: TextStyle(
                              fontSize: 12,
                              color: isSelected
                                  ? Colors.white
                                  : isFuture
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
