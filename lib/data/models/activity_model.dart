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

class StepsStatsDay {
  final String date;
  final int steps;
  final int goal;

  StepsStatsDay({required this.date, required this.steps, required this.goal});

  factory StepsStatsDay.fromJson(Map<String, dynamic> json) => StepsStatsDay(
    date: json['date'],
    steps: json['steps'],
    goal: json['goal'],
  );
}

class StepsStatsResponse {
  final List<StepsStatsDay> days;
  final int averageSteps;
  final int totalSteps;

  StepsStatsResponse({
    required this.days,
    required this.averageSteps,
    required this.totalSteps,
  });

  factory StepsStatsResponse.fromJson(Map<String, dynamic> json) =>
      StepsStatsResponse(
        days: (json['days'] as List)
            .map((d) => StepsStatsDay.fromJson(d))
            .toList(),
        averageSteps: json['average_steps'],
        totalSteps: json['total_steps'],
      );
}
