import 'package:conquest/presentation/viewmodels/map_viewmodel.dart';
import 'package:conquest/presentation/views/shared_widgets/glass_container.dart';
import 'package:conquest/presentation/views/shared_widgets/sessions_expanded.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';

class ExpandedSessionList extends ConsumerWidget {
  final VoidCallback onCollapse;
  const ExpandedSessionList({super.key, required this.onCollapse});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(mapProvider);
    final sessions = state.dayLog?.sessions ?? [];

    return GlassContainer(
      borderRadius: 16,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SvgPicture.asset('assets/icons/session.svg', width: 20),
                const SizedBox(width: 4),
                const Expanded(
                  child: Center(
                    child: Text(
                      'Sessions',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                GestureDetector(
                  onTap: onCollapse,
                  child: SvgPicture.asset(
                    'assets/icons/collapse.svg',
                    width: 20,
                  ),
                ),
              ],
            ),
            Flexible(
              child: SingleChildScrollView(
                child: SessionsExpanded(
                  mutedColor: Theme.of(
                    context,
                  ).colorScheme.onSurface.withValues(alpha: 0.50),
                  sessions: sessions,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
