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
  factory UserModel.fromMap(Map<String, dynamic> m) {
    return UserModel(
      id: m['id'],
      username: m['username'],
      fullName: m['full_name'],
      profilePhoto: m['profile_photo'],
      isPremium: m['is_premium'] == 1,
      level: m['level'],
      league: m['league'],
      allTimeXp: m['all_time_xp'],
      xpToNextLevel: m['xp_to_next_level'],
      totalSteps: m['total_steps'],
      weeklyPoints: m['weekly_points'],
      currentStreak: m['current_streak'],
      longestStreak: m['longest_streak'],
      createdAt: m['created_at'],
    );
  }

  Map<String, dynamic> toMap() => {
    'id': id,
    'username': username,
    'full_name': fullName,
    'profile_photo': profilePhoto,
    'is_premium': isPremium ? 1 : 0,
    'level': level,
    'league': league,
    'all_time_xp': allTimeXp,
    'xp_to_next_level': xpToNextLevel,
    'total_steps': totalSteps,
    'weekly_points': weeklyPoints,
    'current_streak': currentStreak,
    'longest_streak': longestStreak,
    'created_at': createdAt,
  };
}
