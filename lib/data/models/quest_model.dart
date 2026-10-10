class QuestObjectModel {
  final int id;
  final String label;
  final String difficulty;
  final String? imageUrl;

  QuestObjectModel({
    required this.id,
    required this.label,
    required this.difficulty,
    this.imageUrl,
  });

  factory QuestObjectModel.fromJson(Map<String, dynamic> json) {
    return QuestObjectModel(
      id: json['id'],
      label: json['label'],
      difficulty: json['difficulty'],
      imageUrl: json['image_url'],
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

  factory QuestModel.fromLocal(Map<String, dynamic> row, {int? stepGoal}) {
    return QuestModel(
      date: row['date'],
      stepGoal: stepGoal,
      object1: row['object1_id'] != null
          ? QuestObjectModel(
              id: row['object1_id'],
              label: row['object1_label'],
              difficulty: row['object1_difficulty'],
              imageUrl: row['object1_image_url'],
            )
          : null,
      object2: row['object2_id'] != null
          ? QuestObjectModel(
              id: row['object2_id'],
              label: row['object2_label'],
              difficulty: row['object2_difficulty'],
              imageUrl: row['object2_image_url'],
            )
          : null,
      object1Completed: row['object1_completed'] == 1,
      object2Completed: row['object2_completed'] == 1,
    );
  }
}