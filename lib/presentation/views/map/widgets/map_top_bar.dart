import 'package:conquest/presentation/viewmodels/map_viewmodel.dart';
import 'package:conquest/presentation/views/shared_widgets/glass_container.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';

class MapTopBar extends ConsumerWidget {
  final VoidCallback onDateTap;

  const MapTopBar({super.key, required this.onDateTap});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(mapProvider);
    final date = state.selectedDate;
    final now = DateTime.now();
    final isToday =
        date.year == now.year && date.month == now.month && date.day == now.day;

    String label;
    if (isToday) {
      label = 'Today';
    } else {
      label =
          '${date.day} ${_month(date.month)} ${date.year != now.year ? date.year.toString() : ''}';
    }

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(0,16,0,10),
        child: Align(
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
                    onTap: () => ref.read(mapProvider.notifier).navigateDate(-1),
                    child: SvgPicture.asset('assets/icons/nav_left.svg'),
                  ),
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: onDateTap,
                    child: SizedBox(
                      width: 120,
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
                    onTap: isToday
                        ? null
                        : () => ref.read(mapProvider.notifier).navigateDate(1),
                    child: Opacity(
                      opacity: isToday ? 0.3 : 1.0,
                      child: SvgPicture.asset(
                        'assets/icons/nav_right.svg',
                        colorFilter: const ColorFilter.mode(
                          Colors.black,
                          BlendMode.srcIn,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _month(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return months[month - 1];
  }
}
