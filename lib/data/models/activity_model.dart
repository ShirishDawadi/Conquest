class ActivitySyncRequest {
  final String date;
  final int steps;

  ActivitySyncRequest({required this.date, required this.steps});

  Map<String, dynamic> toJson() => {'date': date, 'steps': steps};
}

class ActivityLog {
  final int id;
  final int userId;
  final String date;
  final int steps;

  ActivityLog({
    required this.id,
    required this.userId,
    required this.date,
    required this.steps,
  });

  factory ActivityLog.fromJson(Map<String, dynamic> json) => ActivityLog(
    id: json['id'],
    userId: json['user_id'],
    date: json['date'],
    steps: json['steps'],
  );
}
