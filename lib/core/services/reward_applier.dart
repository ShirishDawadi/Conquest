import 'package:conquest/data/models/reward_model.dart';
import 'package:conquest/data/sources/local/summary_local_source.dart';

class RewardApplier {
  static Future<void> apply({
    required DateTime date,
    required String actionType,
    String? tier,
    required int xpEarned,
    required int pointsEarned,
    required void Function(DateTime normalizedDate) invalidate,
  }) async {
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