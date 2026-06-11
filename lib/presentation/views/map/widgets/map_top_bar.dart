import 'package:conquest/presentation/viewmodels/map_viewmodel.dart';
import 'package:conquest/presentation/views/shared_widgets/glass_container.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MapTopBar extends ConsumerWidget {
  const MapTopBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(mapProvider);
    final date = state.selectedDate;
    final now = DateTime.now();
    final isToday = date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;

    String label;
    if (isToday) {
      label = 'Today';
    } else {
      label =
          '${date.day} ${_month(date.month)} ${date.year != now.year ? date.year.toString() : ''}';
    }

    final isFuture = date.isAfter(DateTime(now.year, now.month, now.day));

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Align(
          alignment: Alignment.center,
          child: GlassContainer(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left),
                  onPressed: () =>
                      ref.read(mapProvider.notifier).navigateDate(-1),
                ),
                SizedBox(
                  width: 90,
                  child: Text(
                    label.trim(),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(
                    Icons.chevron_right,
                    color: isFuture ? Colors.grey.withValues(alpha: 0.3) : null,
                  ),
                  onPressed: isFuture
                      ? null
                      : () => ref.read(mapProvider.notifier).navigateDate(1),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _month(int month) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return months[month - 1];
  }
}