import 'package:conquest/data/models/reward_model.dart';
import 'package:conquest/data/models/user_progress_model.dart';
import 'package:conquest/data/sources/local/summary_local_source.dart';

class RewardApplier {
  static Future<void> Function(UserProgress p)? onProgress;

  static void Function(int, int, String, int?, bool)? onReward;

  static Future<void> applyProgress(UserProgress? p) async {
    if (p == null) return;
    await onProgress?.call(p);
  }

  static void animateOnly(
    int xp,
    int points,
    String actionType, {
    int? objectId,
  }) => onReward?.call(xp, points, actionType, objectId, true);

  static Future<void> apply({
    required DateTime date,
    required String actionType,
    String? tier,
    int? objectId,
    required int xpEarned,
    required int pointsEarned,
    UserProgress? progress,
    required void Function(DateTime normalizedDate) invalidate,
  }) async {
    if (progress != null && (xpEarned > 0 || pointsEarned > 0)) {
      onReward?.call(xpEarned, pointsEarned, actionType, objectId, false);
    }

    await applyProgress(progress);

    if (xpEarned == 0 && pointsEarned == 0) return;

    final normalized = DateTime(date.year, date.month, date.day);
    final reward = UserRewardModel(
      actionType: actionType,
      tier: tier,
      xpEarned: xpEarned,
      pointsEarned: pointsEarned,
      date: normalized,
    );

    await SummaryLocalSource().insertRewards(normalized, [reward]);
    invalidate(normalized);
  }
}