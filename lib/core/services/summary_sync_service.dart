import 'dart:developer';
import 'package:conquest/core/utils/connectivity_utils.dart';
import 'package:conquest/data/sources/local/activity_local_source.dart';
import 'package:conquest/data/sources/local/map_local_source.dart';
import 'package:conquest/data/sources/local/summary_local_source.dart';
import 'package:conquest/data/sources/remote/summary_remote_source.dart';
import 'package:conquest/data/models/summary_model.dart';
import 'package:conquest/data/models/quest_model.dart';

class SummarySyncService {
  static final SummarySyncService _instance = SummarySyncService._internal();
  factory SummarySyncService() => _instance;
  SummarySyncService._internal();

  final _questLocal = SummaryLocalSource();
  final _activityLocal = ActivityLocalSource();
  final _mapLocal = MapLocalSource();
  final _remote = SummaryRemoteSource();

  Future<DaySummaryModel?> getDaySummary(DateTime date) async {
    final questRow = await _questLocal.getQuest(date);
    final activityRow = await _activityLocal.getLog(date);

    if (questRow != null && activityRow != null) {
      final sessions = await _mapLocal.getLog(date);
      final rewards = await _questLocal.getRewards(date);
      return DaySummaryModel(
        date: date,
        stepGoal: activityRow['steps_goal'] as int,
        stepsAchieved: activityRow['steps_achieved'] as int,
        object1: QuestObjectModel(
          id: questRow['object1_id'] as int,
          label: questRow['object1_label'] as String,
          difficulty: questRow['object1_difficulty'] as String,
          imageUrl: questRow['object1_image_url'] as String?,
        ),
        object2: QuestObjectModel(
          id: questRow['object2_id'] as int,
          label: questRow['object2_label'] as String,
          difficulty: questRow['object2_difficulty'] as String,
          imageUrl: questRow['object2_image_url'] as String?,
        ),
        object1Completed: (questRow['object1_completed'] as int) == 1,
        object2Completed: (questRow['object2_completed'] as int) == 1,
        gpsSessions: sessions?.sessions ?? [],
        rewards: rewards,
      );
    }

    try {
      if (!await ConnectivityUtils.isOnline()) return null;

      final remoteSummary = await _remote.getDaySummary(date);

      await _questLocal.upsertQuest(
        date: date,
        object1: remoteSummary.object1,
        object2: remoteSummary.object2,
        object1Completed: remoteSummary.object1Completed,
        object2Completed: remoteSummary.object2Completed,
      );

      await _activityLocal.upsertSyncedSteps(
        date: date,
        steps: remoteSummary.stepsAchieved,
        goal: remoteSummary.stepGoal,
      );

      final localSessions = await _mapLocal.getLog(date);
      if (localSessions != null && localSessions.sessions.isNotEmpty) {
        return remoteSummary.copyWith(gpsSessions: localSessions.sessions);
      }
      return remoteSummary;
    } catch (e) {
      log(
        'SummarySyncService getDaySummary failed: $e',
        name: 'SummarySyncService',
      );
      return null;
    }
  }
}
