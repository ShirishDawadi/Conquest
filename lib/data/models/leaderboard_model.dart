class LeaderboardEntry {
  final int rank;
  final int userId;
  final String username;
  final String? profilePhoto;
  final int points;

  LeaderboardEntry({
    required this.rank,
    required this.userId,
    required this.username,
    this.profilePhoto,
    required this.points,
  });

  factory LeaderboardEntry.fromJson(Map<String, dynamic> json) {
    return LeaderboardEntry(
      rank: json['rank'],
      userId: json['user_id'],
      username: json['username'],
      profilePhoto: json['profile_photo'],
      points: json['points'],
    );
  }
}