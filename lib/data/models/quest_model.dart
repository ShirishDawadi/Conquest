class QuestObjectModel {
  final int id;
  final String label;
  final String difficulty;

  QuestObjectModel({
    required this.id,
    required this.label,
    required this.difficulty,
  });

  factory QuestObjectModel.fromJson(Map<String, dynamic> json) {
    return QuestObjectModel(
      id: json['id'],
      label: json['label'],
      difficulty: json['difficulty'],
    );
  }
}

class QuestModel {
  final bool? reset;
  final int? id;
  final String? date;
  final int? stepGoal;
  final QuestObjectModel? object1;
  final QuestObjectModel? object2;
  final bool? stepsCompleted;
  final bool? object1Completed;
  final bool? object2Completed;
  final String? completedAt;
  final int? pointsEarned;

  QuestModel({
    this.reset,
    this.id,
    this.date,
    this.stepGoal,
    this.object1,
    this.object2,
    this.stepsCompleted,
    this.object1Completed,
    this.object2Completed,
    this.completedAt,
    this.pointsEarned,
  });

  bool get needsReset => reset == true;

  factory QuestModel.fromJson(Map<String, dynamic> json) {
    return QuestModel(
      reset: json['reset'],
      id: json['id'],
      date: json['date'],
      stepGoal: json['step_goal'],
      object1: json['object1'] != null
          ? QuestObjectModel.fromJson(json['object1'])
          : null,
      object2: json['object2'] != null
          ? QuestObjectModel.fromJson(json['object2'])
          : null,
      stepsCompleted: json['steps_completed'],
      object1Completed: json['object1_completed'],
      object2Completed: json['object2_completed'],
      completedAt: json['completed_at'],
      pointsEarned: json['points_earned'],
    );
  }
}