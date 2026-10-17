import 'dart:developer';
import 'package:conquest/core/network/api_client.dart';
import 'package:conquest/data/models/gps_model.dart';
import 'package:conquest/data/models/user_progress_model.dart';

class MapSyncResult {
  final int id;
  final int xpEarned;
  final int pointsEarned;
  final UserProgress? user;

  MapSyncResult({
    required this.id,
    required this.xpEarned,
    required this.pointsEarned,
    this.user,
  });
}

class MapRemoteSource {
  Future<MapSyncResult> syncSession(DateTime date, GpsSession session) async {
    try {
      final dateStr = date.toIso8601String().substring(0, 10);
      final response = await ApiClient.instance.post(
        '/map/sync',
        data: session.toJson(),
        queryParameters: {'target_date': dateStr},
      );
      final d = response.data as Map<String, dynamic>;
      return MapSyncResult(
        id: d['id'] as int,
        xpEarned: d['xp_earned'] as int? ?? 0,
        pointsEarned: d['points_earned'] as int? ?? 0,
        user: UserProgress.tryParse(d['user']),
      );
    } catch (e) {
      log('MapRemoteSource syncSession failed: $e', name: 'MapRemoteSource');
      rethrow;
    }
  }

  Future<List<GpsSession>> getDaySessions(DateTime date) async {
    try {
      final dateStr = date.toIso8601String().substring(0, 10);
      final response = await ApiClient.instance.get('/map/$dateStr');
      return (response.data as List)
          .map((e) => GpsSession.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      log('MapRemoteSource getDaySessions failed: $e', name: 'MapRemoteSource');
      rethrow;
    }
  }

  Future<List<GpsSession>> getMonthHistory(DateTime month) async {
    try {
      final monthStr =
          '${month.year}-${month.month.toString().padLeft(2, '0')}';
      final response = await ApiClient.instance.get(
        '/map/history',
        queryParameters: {'month': monthStr},
      );
      return (response.data as List)
          .map((e) => GpsSession.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      log(
        'MapRemoteSource getMonthHistory failed: $e',
        name: 'MapRemoteSource',
      );
      rethrow;
    }
  }

  Future<void> deleteSession(DateTime date, int backendId) async {
    try {
      final dateStr = date.toIso8601String().substring(0, 10);
      await ApiClient.instance.delete('/map/$dateStr/session/$backendId');
    } catch (e) {
      log('MapRemoteSource deleteSession failed: $e', name: 'MapRemoteSource');
      rethrow;
    }
  }
}
