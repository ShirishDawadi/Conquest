import 'package:conquest/core/utils/tracking_utils.dart';
import 'package:conquest/data/models/gps_model.dart';
import 'package:conquest/presentation/viewmodels/map_viewmodel.dart';
import 'package:conquest/presentation/views/shared_widgets/glass_container.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';

class SessionList extends ConsumerStatefulWidget {
  final bool isMonthView;
  final VoidCallback onExpand;

  const SessionList({
    super.key,
    required this.isMonthView,
    required this.onExpand,
  });

  @override
  ConsumerState<SessionList> createState() => _SessionListState();
}

class _SessionListState extends ConsumerState<SessionList> {
  final ScrollController controller = ScrollController();

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(mapProvider);
    final sessions = state.dayLog?.sessions ?? [];
    final len = sessions.length;

    if (sessions.isEmpty) return const SizedBox.shrink();

    return GlassContainer(
      borderRadius: 12,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 10.0),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6.0),
              child: Row(
                children: [
                  const SizedBox(width: 8),
                  SvgPicture.asset('assets/icons/session.svg', width: 15),
                  const SizedBox(width: 4),
                  const Expanded(
                    child: Text(
                      'Sessions',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  if (!widget.isMonthView)
                    Text('$len/10', style: const TextStyle(fontSize: 10)),
                  const SizedBox(width: 4),
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: widget.onExpand,
                    child: SvgPicture.asset('assets/icons/expand.svg', width: 15),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 4),
            Container(
              constraints: const BoxConstraints(maxHeight: 100),
              child: ListView.builder(
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                itemCount: len,
                itemBuilder: (context, index) {
                  final session = sessions[index];
                  return _SessionTile(index: index + 1, session: session);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SessionTile extends ConsumerWidget {
  final int index;
  final GpsSession session;

  const _SessionTile({required this.index, required this.session});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dist = session.distanceKm;
    String distStr = '${dist.toStringAsFixed(1)}km';
    if (dist < 1) {
      distStr = '${(dist * 1000).toStringAsFixed(0)}m';
    }

    final durStr = TrackingUtils.formatDuration(session.duration);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => ref.read(mapProvider.notifier).focusSession(session),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.white),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 14,
                  child: Text('$index.', style: const TextStyle(fontSize: 10)),
                ),
                const SizedBox(width: 5),
                Expanded(
                  child: Row(
                    children: [
                      SvgPicture.asset('assets/icons/distance.svg', width: 15),
                      const SizedBox(width: 2),
                      Text(distStr, style: const TextStyle(fontSize: 10)),
                    ],
                  ),
                ),
                SvgPicture.asset('assets/icons/time.svg', width: 15),
                Text(durStr, style: const TextStyle(fontSize: 10)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}