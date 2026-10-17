class UserProgress {
  final int level;
  final String league;
  final int allTimeXp;
  final int xpToNextLevel;
  final int weeklyPoints;
  final int currentStreak;
  final int longestStreak;

  const UserProgress({
    required this.level,
    required this.league,
    required this.allTimeXp,
    required this.xpToNextLevel,
    required this.weeklyPoints,
    required this.currentStreak,
    required this.longestStreak,
  });

  factory UserProgress.fromJson(Map<String, dynamic> j) => UserProgress(
    level: j['level'],
    league: j['league'],
    allTimeXp: j['all_time_xp'],
    xpToNextLevel: j['xp_to_next_level'],
    weeklyPoints: j['weekly_points'],
    currentStreak: j['current_streak'],
    longestStreak: j['longest_streak'],
  );

  static UserProgress? tryParse(dynamic j) =>
      j is Map<String, dynamic> ? UserProgress.fromJson(j) : null;
}