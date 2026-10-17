class RewardRule {
  final String actionType;
  final String? tier;
  final int xp;
  final int points;

  const RewardRule({
    required this.actionType,
    this.tier,
    required this.xp,
    required this.points,
  });

  factory RewardRule.fromJson(Map<String, dynamic> j) => RewardRule(
    actionType: j['action_type'],
    tier: j['tier'],
    xp: j['xp'],
    points: j['points'],
  );
}

class GameRules {
  final int version;
  final List<RewardRule> rules;

  const GameRules({required this.version, required this.rules});

  static const defaults = GameRules(
    version: 0,
    rules: [
      RewardRule(actionType: 'steps_completed', xp: 10, points: 10),
      RewardRule(actionType: 'object_completed', tier: 'easy', xp: 10, points: 10),
      RewardRule(actionType: 'object_completed', tier: 'medium', xp: 15, points: 15),
      RewardRule(actionType: 'object_completed', tier: 'hard', xp: 20, points: 20),
      RewardRule(actionType: 'distance_done', tier: '500m', xp: 10, points: 0),
      RewardRule(actionType: 'distance_done', tier: '1km', xp: 10, points: 0),
      RewardRule(actionType: 'distance_done', tier: '2km', xp: 10, points: 0),
    ],
  );

  factory GameRules.fromJson(Map<String, dynamic> j) => GameRules(
    version: j['version'],
    rules: (j['rules'] as List)
        .map((e) => RewardRule.fromJson(e as Map<String, dynamic>))
        .toList(),
  );

  RewardRule? _find(String action, String? tier) {
    for (final r in rules) {
      if (r.actionType == action && r.tier == tier) return r;
    }
    return null;
  }

  int xp(String action, [String? tier]) => _find(action, tier)?.xp ?? 0;
  int points(String action, [String? tier]) => _find(action, tier)?.points ?? 0;
}