import 'package:conquest/data/models/quest_model.dart';
import 'package:conquest/data/sources/local/map_local_source.dart';
import 'package:conquest/data/sources/local/object_image_local_source.dart';
import 'package:conquest/data/sources/local/summary_local_source.dart';
import 'package:conquest/presentation/viewmodels/quest_viewmodel.dart';
import 'package:conquest/presentation/viewmodels/rules_viewmodel.dart';
import 'package:conquest/presentation/viewmodels/step_viewmodel.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PendingRewards {
  final int xp;
  final int points;
  const PendingRewards(this.xp, this.points);

  bool get isEmpty => xp <= 0 && points <= 0;
}

final stepsGoalReachedProvider = Provider<bool>((ref) {
  final steps = ref.watch(stepProvider).value ?? 0;
  final goal = ref.watch(questProvider).value?.stepGoal ?? 500;
  return steps > 0 && steps >= goal;
});

String? _tier(double meters) {
  if (meters >= 2000) return '2km';
  if (meters >= 1000) return '1km';
  if (meters >= 500) return '500m';
  return null;
}

final pendingRewardsProvider = FutureProvider<PendingRewards>((ref) async {
  final rules = ref.watch(rulesProvider);
  final quest = ref.watch(questProvider).value;
  final stepsReached = ref.watch(stepsGoalReachedProvider);
  ref.watch(stepsSyncedProvider);

  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final todayStr = today.toIso8601String().substring(0, 10);

  int xp = 0;
  int points = 0;

  final q = quest;
  if (q != null) {
    final rows = await ObjectImageLocalSource().getPending();
    final seen = <int>{};
    for (final r in rows) {
      if (q.id != null && r['quest_id'] != q.id) continue;
      final objectId = r['object_id'] as int;
      if (!seen.add(objectId)) continue;

      final obj = [q.object1, q.object2]
          .whereType<QuestObjectModel>()
          .where((o) => o.id == objectId)
          .firstOrNull;
      if (obj == null) continue;

      xp += rules.xp('object_completed', obj.difficulty);
      points += rules.points('object_completed', obj.difficulty);
    }
  }

  if (q != null && stepsReached && q.stepsCompleted != true) {
    final goal = q.stepGoal ?? 500;
    final syncedSteps = ref
        .read(stepsSyncedProvider.notifier)
        .valueFor(todayStr);
    final paidLocally = (await SummaryLocalSource().getRewards(
      today,
    )).any((r) => r.actionType == 'steps_completed');

    if (syncedSteps < goal && !paidLocally) {
      xp += rules.xp('steps_completed');
      points += rules.points('steps_completed');
    }
  }

  final mapLocal = MapLocalSource();
  final unsynced = await mapLocal.getUnsyncedSessions();
  double bestUnsyncedM = 0;
  for (final s in unsynced) {
    final d = s.startedAt;
    if (d.year == today.year && d.month == today.month && d.day == today.day) {
      final m = s.furthestDistanceKm * 1000;
      if (m > bestUnsyncedM) bestUnsyncedM = m;
    }
  }

  if (bestUnsyncedM > 0) {
    final log = await mapLocal.getLog(today);
    double bestSyncedM = 0;
    for (final s in log?.sessions ?? const []) {
      if (s.backendId != null) {
        final m = s.furthestDistanceKm * 1000;
        if (m > bestSyncedM) bestSyncedM = m;
      }
    }

    final bestAll = bestUnsyncedM > bestSyncedM ? bestUnsyncedM : bestSyncedM;
    final allTier = _tier(bestAll);
    final syncedTier = _tier(bestSyncedM);
    if (allTier != null && allTier != syncedTier) {
      final total = rules.xp('distance_done', allTier);
      final paid = syncedTier == null
          ? 0
          : rules.xp('distance_done', syncedTier);
      final diff = total - paid;
      if (diff > 0) xp += diff;
    }
  }

  return PendingRewards(xp, points);
});
