import 'package:conquest/core/utils/tracking_utils.dart';
import 'package:conquest/data/models/gps_model.dart';
import 'package:conquest/presentation/viewmodels/map_viewmodel.dart';
import 'package:conquest/presentation/views/shared_widgets/glass_container.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SessionList extends ConsumerStatefulWidget {
  const SessionList({super.key});

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

    if (sessions.isEmpty) return const SizedBox.shrink();

    return GlassContainer(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            const Text(
              'Sessions',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            const SizedBox(height: 4),
            Container(
              constraints: const BoxConstraints(maxHeight: 105),
              child: ListView.builder(
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                itemCount: sessions.length,
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
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(0.0, 4.0, 6.0, 4.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('$index.', style: const TextStyle(fontSize: 12)),
                const SizedBox(width: 5),
                Expanded(
                  child: Text(distStr, style: const TextStyle(fontSize: 12)),
                ),
                Text(durStr, style: const TextStyle(fontSize: 12)),
              ],
            ),
          ),
          Container(
            height: 1,
            width: 120,
            color: Colors.white.withValues(alpha: 0.5),
          ),
        ],
      ),
    );
  }
}
