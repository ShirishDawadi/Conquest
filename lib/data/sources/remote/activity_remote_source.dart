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
}