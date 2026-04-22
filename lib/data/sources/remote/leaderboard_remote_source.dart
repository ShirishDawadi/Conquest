import 'dart:developer';
import 'package:conquest/core/network/api_client.dart';
import 'package:conquest/data/models/leaderboard_model.dart';

class LeaderboardRemoteSource {
  final _dio = ApiClient.instance;

  Future<List<LeaderboardEntry>> getWeekly() async {
    try {
      final response = await _dio.get('/leaderboard/weekly');
      return (response.data as List)
          .map((e) => LeaderboardEntry.fromJson(e))
          .toList();
    } catch (e) {
      log('Error fetching weekly leaderboard: $e', name: 'LeaderboardRemoteSource');
      rethrow;
    }
  }

  Future<List<LeaderboardEntry>> getHallOfFameXp() async {
    try {
      final response = await _dio.get('/leaderboard/hall-of-fame/xp');
      return (response.data as List)
          .map((e) => LeaderboardEntry.fromJson(e))
          .toList();
    } catch (e) {
      log('Error fetching hall of fame xp: $e', name: 'LeaderboardRemoteSource');
      rethrow;
    }
  }

  Future<List<LeaderboardEntry>> getHallOfFameSteps() async {
    try {
      final response = await _dio.get('/leaderboard/hall-of-fame/steps');
      return (response.data as List)
          .map((e) => LeaderboardEntry.fromJson(e))
          .toList();
    } catch (e) {
      log('Error fetching hall of fame steps: $e', name: 'LeaderboardRemoteSource');
      rethrow;
    }
  }
}