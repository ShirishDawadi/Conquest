class UserModel {
  final int id;
  final String username;
  final String? fullName;
  final String? profilePhoto;
  final bool isPremium;
  final int level;
  final String league;
  final int allTimeXp;
  final int xpToNextLevel;
  final int totalSteps;
  final int weeklyPoints;
  final int currentStreak;
  final int longestStreak;
  final String createdAt;

  UserModel({
    required this.id,
    required this.username,
    this.fullName,
    this.profilePhoto,
    required this.isPremium,
    required this.level,
    required this.league,
    required this.allTimeXp,
    required this.xpToNextLevel,
    required this.totalSteps,
    required this.weeklyPoints,
    required this.currentStreak,
    required this.longestStreak,
    required this.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      username: json['username'],
      fullName: json['full_name'],
      profilePhoto: json['profile_photo'],
      isPremium: json['is_premium'],
      level: json['level'],
      league: json['league'],
      allTimeXp: json['all_time_xp'],
      xpToNextLevel: json['xp_to_next_level'],
      totalSteps: json['total_steps'],
      weeklyPoints: json['weekly_points'],
      currentStreak: json['current_streak'],
      longestStreak: json['longest_streak'],
      createdAt: json['created_at'],
    );
  }
}