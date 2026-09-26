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
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SvgPicture.asset('assets/icons/session.svg', width: 24),
                  const Expanded(
                    child: Center(
                      child: Text(
                        'Sessions',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: onCollapse,
                    child: SvgPicture.asset(
                      'assets/icons/collapse.svg',
                      width: 24,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 5),
            Flexible(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.white.withValues(alpha: 0.50),
                ),
                padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 2.0),
                child: SingleChildScrollView(
                  child: SessionsExpanded(
                    mutedColor: Colors.grey,
                    sessions: sessions,
                    onSessionTap: (session) {
                      ref.read(mapProvider.notifier).focusSession(session);
                      onCollapse();
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
