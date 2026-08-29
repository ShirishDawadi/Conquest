import 'package:conquest/data/models/quest_model.dart';
import 'package:conquest/data/models/gps_model.dart';
import 'package:conquest/data/models/reward_model.dart';

class DaySummaryModel {
  final DateTime date;
  final int stepGoal;
  final int stepsAchieved;
  final QuestObjectModel object1;
  final QuestObjectModel object2;
  final bool object1Completed;
  final bool object2Completed;
  final List<GpsSession> gpsSessions;
  final List<UserRewardModel> rewards;

  DaySummaryModel({
    required this.date,
    required this.stepGoal,
    required this.stepsAchieved,
    required this.object1,
    required this.object2,
    required this.object1Completed,
    required this.object2Completed,
    required this.gpsSessions,
    required this.rewards,
  });

  factory DaySummaryModel.fromJson(Map<String, dynamic> json) {
    return DaySummaryModel(
      date: DateTime.parse(json['date'] as String),
      stepGoal: json['step_goal'] as int,
      stepsAchieved: json['steps_achieved'] as int,
      object1: QuestObjectModel.fromJson(json['object1']),
      object2: QuestObjectModel.fromJson(json['object2']),
      object1Completed: json['object1_completed'] as bool,
      object2Completed: json['object2_completed'] as bool,
      gpsSessions: (json['gps_sessions'] as List)
          .map((p) => GpsSession.fromJson(p as Map<String, dynamic>))
          .toList(),
      rewards: (json['rewards'] as List? ?? [])
          .map((r) => UserRewardModel.fromJson(r as Map<String, dynamic>))
          .toList(),
    );
  }

  DaySummaryModel copyWith({
    List<GpsSession>? gpsSessions,
    List<UserRewardModel>? rewards,
  }) {
    return DaySummaryModel(
      date: date,
      stepGoal: stepGoal,
      stepsAchieved: stepsAchieved,
      object1: object1,
      object2: object2,
      object1Completed: object1Completed,
      object2Completed: object2Completed,
      gpsSessions: gpsSessions ?? this.gpsSessions,
      rewards: rewards ?? this.rewards,
    );
  }

  int get totalXpEarned => rewards.fold(0, (sum, r) => sum + r.xpEarned);
  int get totalPointsEarned => rewards.fold(0, (sum, r) => sum + r.pointsEarned);

  int? get stepsXp => rewards
      .where((r) => r.actionType == 'steps_completed')
      .fold<int?>(null, (_, r) => r.xpEarned);

  List<UserRewardModel> get objectRewards =>
      rewards.where((r) => r.actionType == 'object_completed').toList();

  int? get distanceXp => rewards
      .where((r) => r.actionType == 'distance_done')
      .fold<int?>(null, (_, r) => r.xpEarned);
}