import 'dart:developer';
import 'package:conquest/core/network/api_client.dart';
import 'package:conquest/data/models/quest_model.dart';

class QuestRemoteSource {
  final _dio = ApiClient.instance;

  Future<QuestModel> getTodayQuest() async {
    try {
      final response = await _dio.get('/quests/today');
      return QuestModel.fromJson(response.data);
    } catch (e) {
      log('Error fetching quest: $e', name: 'QuestRemoteSource');
      rethrow;
    }
  }

  Future<QuestModel> setupQuest(int stepGoal) async {
    try {
      final response = await _dio.post(
        '/quests/today/setup?step_goal=$stepGoal',
      );
      return QuestModel.fromJson(response.data);
    } catch (e) {
      log('Error setting up quest: $e', name: 'QuestRemoteSource');
      rethrow;
    }
  }
}