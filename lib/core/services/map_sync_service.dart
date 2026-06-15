import 'dart:developer';
import 'package:conquest/data/models/gps_model.dart';
import 'package:conquest/data/sources/local/map_local_source.dart';
import 'package:conquest/data/sources/remote/map_remote_source.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class MapSyncService {
  static final MapSyncService _instance = MapSyncService._internal();
  factory MapSyncService() => _instance;
  MapSyncService._internal();

  final _local = MapLocalSource();
  final _remote = MapRemoteSource();

  Future<void> saveAndSync(GpsLog gpsLog) async {
    await _local.upsertLog(gpsLog.date, gpsLog.sessions);
    await _trySync(gpsLog);
  }

  Future<void> _trySync(GpsLog gpsLog) async {
    try {
      final connectivity = await Connectivity().checkConnectivity();
      if (connectivity.contains(ConnectivityResult.none)) return;
      await _remote.syncLog(gpsLog);
      await _local.markSynced(gpsLog.date);
    } catch (e) {
      log('MapSyncService sync failed: $e', name: 'MapSyncService');
    }
  }

  Future<void> retryUnsynced() async {
    try {
      final connectivity = await Connectivity().checkConnectivity();
      if (connectivity.contains(ConnectivityResult.none)) return;

      final unsynced = await _local.getUnsyncedLogs();
      for (final gpsLog in unsynced) {
        try {
          await _remote.syncLog(gpsLog);
          await _local.markSynced(gpsLog.date);
          log('MapSyncService synced ${gpsLog.date}', name: 'MapSyncService');
        } catch (e) {
          log(
            'MapSyncService retry failed for ${gpsLog.date}: $e',
            name: 'MapSyncService',
          );
        }
      }
    } catch (e) {
      log('MapSyncService retryUnsynced failed: $e', name: 'MapSyncService');
    }
  }

  Future<GpsLog?> getLog(DateTime date) async {
    final local = await _local.getLog(date);
    if (local != null) return local;

    try {
      final remote = await _remote.getDayLog(date);
      if (remote != null) {
        await _local.upsertSyncedLog(remote.date, remote.sessions);
      }
      return remote;
    } catch (e) {
      log('MapSyncService getLog remote failed: $e', name: 'MapSyncService');
      return null;
    }
  }

  Future<void> deleteSession(DateTime date, int sessionId) async {
    try {
      final connectivity = await Connectivity().checkConnectivity();
      if (!connectivity.contains(ConnectivityResult.none)) {
        await _remote.deleteSession(date, sessionId);
      }
    } catch (e) {
      log(
        'MapSyncService deleteSession remote failed: $e',
        name: 'MapSyncService',
      );
    }
  }

  Future<void> deleteLog(DateTime date) async {
    await _local.deleteLog(date);
  }

  Future<void> cleanOldLogs() async {
    await _local.deleteOldLogs();
  }
}
