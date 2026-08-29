class UserRewardModel {
  final String actionType;
  final String? tier;
  final int xpEarned;
  final int pointsEarned;
  final DateTime date;

  UserRewardModel({
    required this.actionType,
    this.tier,
    required this.xpEarned,
    required this.pointsEarned,
    required this.date,
  });

  factory UserRewardModel.fromJson(Map<String, dynamic> json) {
    return UserRewardModel(
      actionType: json['action_type'] as String,
      tier: json['tier'] as String?,
      xpEarned: json['xp_earned'] as int,
      pointsEarned: json['gems_earned'] as int,
      date: DateTime.parse(json['date'] as String),
    );
  }

  factory UserRewardModel.fromDb(Map<String, dynamic> row) {
    return UserRewardModel(
      actionType: row['action_type'] as String,
      tier: row['tier'] as String?,
      xpEarned: row['xp_earned'] as int,
      pointsEarned: row['points_earned'] as int,
      date: DateTime.parse(row['date'] as String),
    );
  }

  Map<String, dynamic> toDbMap(DateTime forDate) {
    String fmt(DateTime d) => d.toIso8601String().substring(0, 10);
    return {
      'date': fmt(forDate),
      'action_type': actionType,
      'tier': tier,
      'xp_earned': xpEarned,
      'points_earned': pointsEarned,
    };
  }
}