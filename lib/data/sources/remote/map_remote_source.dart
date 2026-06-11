import 'dart:developer';
import 'package:conquest/core/network/api_client.dart';
import 'package:conquest/data/models/gps_model.dart';

class MapRemoteSource {
  Future<void> syncLog(GpsLog gpsLog) async {
    try {
      await ApiClient.instance.post('/map/sync', data: gpsLog.toJson());
    } catch (e) {
      log('MapRemoteSource syncLog failed: $e', name: 'MapRemoteSource');
      rethrow;
    }
  }

  Future<GpsLog?> getDayLog(DateTime date) async {
    try {
      final dateStr = date.toIso8601String().substring(0, 10);
      final response = await ApiClient.instance.get('/map/$dateStr');
      return GpsLog.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      log('MapRemoteSource getDayLog failed: $e', name: 'MapRemoteSource');
      return null;
    }
  }

  Future<List<GpsLog>> getMonthHistory(DateTime month) async {
    try {
      final monthStr =
          '${month.year}-${month.month.toString().padLeft(2, '0')}';
      final response = await ApiClient.instance.get(
        '/map/history',
        queryParameters: {'month': monthStr},
      );
      return (response.data as List)
          .map((e) => GpsLog.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      log(
        'MapRemoteSource getMonthHistory failed: $e',
        name: 'MapRemoteSource',
      );
      return [];
    }
  }
}
