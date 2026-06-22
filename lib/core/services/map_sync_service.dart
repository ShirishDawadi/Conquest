import 'dart:developer';
import 'package:conquest/core/utils/tracking_utils.dart';
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

  Future<GpsSession> saveAndSync(DateTime date, GpsSession session) async {
    final simplifiedPoints = TrackingUtils.rdp(session.points);
    final simplified = session.copyWith(points: simplifiedPoints);

    final newId = await _local.insertSession(date, simplified);
    final withLocalId = simplified.copyWith(localId: newId);

    final backendId = await _trySync(date, withLocalId);
    return withLocalId.copyWith(backendId: backendId);
  }

  Future<int?> _trySync(DateTime date, GpsSession session) async {
    try {
      final connectivity = await Connectivity().checkConnectivity();
      if (connectivity.contains(ConnectivityResult.none)) return null;
      final backendId = await _remote.syncSession(date, session);
      if (session.localId != null) {
        await _local.markSessionSynced(session.localId!, backendId);
      }
      return backendId;
    } catch (e) {
      log('MapSyncService sync failed: $e', name: 'MapSyncService');
      return null;
    }
  }

  Future<void> retryUnsynced() async {
    try {
      final connectivity = await Connectivity().checkConnectivity();
      if (connectivity.contains(ConnectivityResult.none)) return;

      final unsynced = await _local.getUnsyncedSessions();
      for (final session in unsynced) {
        try {
          final date = DateTime.parse(
            session.startedAt.toIso8601String().substring(0, 10),
          );
          final backendId = await _remote.syncSession(date, session);
          if (session.localId != null) {
            await _local.markSessionSynced(session.localId!, backendId);
          }
          log(
            'MapSyncService synced session ${session.localId}',
            name: 'MapSyncService',
          );
        } catch (e) {
          log(
            'MapSyncService retry failed for session ${session.localId}: $e',
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
      final remoteSessions = await _remote.getDaySessions(date);
      if (remoteSessions == null || remoteSessions.isEmpty) return null;
      await _local.insertSyncedSessions(date, remoteSessions);
      return GpsLog(date: date, sessions: remoteSessions);
    } catch (e) {
      log('MapSyncService getLog remote failed: $e', name: 'MapSyncService');
      return null;
    }
  }

  Future<void> deleteSession(GpsSession session, DateTime date) async {
    log(
      'deleteSession: localId=${session.localId} backendId=${session.backendId}',
      name: 'MapSyncService',
    );

    if (session.localId != null) {
      await _local.deleteSession(session.localId!);
      log('deleteSession: local deleted', name: 'MapSyncService');
    } else {
      log(
        'deleteSession: no localId, skipping local delete',
        name: 'MapSyncService',
      );
    }

    if (session.backendId != null) {
      try {
        final connectivity = await Connectivity().checkConnectivity();
        log(
          'deleteSession: connectivity=${connectivity}',
          name: 'MapSyncService',
        );
        if (!connectivity.contains(ConnectivityResult.none)) {
          await _remote.deleteSession(date, session.backendId!);
          log('deleteSession: backend deleted', name: 'MapSyncService');
        } else {
          log(
            'deleteSession: offline, skipping backend delete',
            name: 'MapSyncService',
          );
        }
      } catch (e) {
        log('deleteSession: remote failed: $e', name: 'MapSyncService');
      }
    } else {
      log(
        'deleteSession: no backendId, skipping backend delete',
        name: 'MapSyncService',
      );
    }
  }

  Future<void> deleteSessionsByDate(DateTime date) async {
    await _local.deleteSessionsByDate(date);
  }

  Future<void> cleanOldSessions() async {
    await _local.deleteOldSessions();
  }
}
