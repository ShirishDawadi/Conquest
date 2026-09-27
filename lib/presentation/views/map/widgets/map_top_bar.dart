import 'package:conquest/core/constants/date_constants.dart';
import 'package:flutter/material.dart';
import 'package:conquest/presentation/views/shared_widgets/glass_container.dart';
import 'package:flutter_svg/svg.dart';

class MapTopBar extends StatelessWidget {
  final VoidCallback onDateTap;
  final bool isMonthView;
  final VoidCallback onPrevious;
  final VoidCallback onNext;
  final DateTime displayDate;

  const MapTopBar({
    super.key,
    required this.onDateTap,
    required this.isMonthView,
    required this.onPrevious,
    required this.onNext,
    required this.displayDate,
  });

  @override
  Widget build(BuildContext context) {
    final date = displayDate;
    final now = DateTime.now();
    final isToday =
        date.year == now.year && date.month == now.month && date.day == now.day;

    final isCurrentMonth = date.year == now.year && date.month == now.month;

    final isNextDisabled = isMonthView ? isCurrentMonth : isToday;

    String label;
    if (isMonthView) {
      label =
          ' ${DateConstants.monthsShort[date.month - 1]} ${date.year != now.year ? date.year.toString() : ''}';
    } else {
      if (isToday) {
        label = 'Today';
      } else {
        label =
            '${date.day} ${DateConstants.monthsShort[date.month - 1]} ${date.year != now.year ? date.year.toString() : ''}';
      }
    }

    final iconColor = Theme.of(context).colorScheme.onSurface;

    return Align(
      alignment: Alignment.center,
      child: GlassContainer(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: onPrevious,
                child: SvgPicture.asset(
                  'assets/icons/nav_left.svg',
                  colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn),
                ),
              ),
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: onDateTap,
                child: SizedBox(
                  width: 100,
                  child: Text(
                    label.trim(),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: isNextDisabled ? null : onNext,
                child: Opacity(
                  opacity: isNextDisabled ? 0.3 : 1.0,
                  child: SvgPicture.asset(
                    'assets/icons/nav_right.svg',
                    colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
