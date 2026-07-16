import 'package:conquest/core/network/api_client.dart';
import 'package:conquest/data/models/activity_model.dart';

class ActivityRemoteSource {
  final _dio = ApiClient.instance;

  Future<ActivityLog> syncActivity(ActivitySyncRequest request) async {
    final response = await _dio.post(
      '/activity/sync',
      data: request.toJson(),
    );
    return ActivityLog.fromJson(response.data);
  }

  Future<StepsStatsResponse> getStepsStats({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final response = await _dio.get(
      '/activity/stats',
      queryParameters: {
        'start_date': startDate.toIso8601String().substring(0, 10),
        'end_date': endDate.toIso8601String().substring(0, 10),
      },
    );
    return StepsStatsResponse.fromJson(response.data);
  }
}