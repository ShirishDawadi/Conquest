import 'dart:convert';
import 'dart:developer';
import 'package:conquest/core/database/app_database.dart';
import 'package:conquest/data/models/gps_model.dart';
import 'package:sqflite/sqflite.dart';

class MapLocalSource {
  static final MapLocalSource _instance = MapLocalSource._internal();
  factory MapLocalSource() => _instance;
  MapLocalSource._internal();

  final _appDb = AppDatabase();

  Future<Database> get _db async => _appDb.database;

  Future<int?> insertSession(DateTime date, GpsSession session) async {
    try {
      final db = await _db;
      final generatedId = await db.insert('gps_sessions', {
        'backend_id': session.backendId,
        'date': date.toIso8601String().substring(0, 10),
        'started_at': session.startedAt.toIso8601String(),
        'ended_at': session.endedAt?.toIso8601String(),
        'points': jsonEncode(session.points.map((p) => p.toJson()).toList()),
        'distance': session.distanceKm,
        'synced': 0,
      });
      return generatedId;
    } catch (e) {
      log('MapLocalSource insertSession failed: $e', name: 'MapLocalSource');
      return null;
    }
  }

  Future<void> markSessionSynced(int localId, int backendId) async {
    try {
      final db = await _db;
      await db.update(
        'gps_sessions',
        {'synced': 1, 'backend_id': backendId},
        where: 'id = ?',
        whereArgs: [localId],
      );
    } catch (e) {
      log(
        'MapLocalSource markSessionSynced failed: $e',
        name: 'MapLocalSource',
      );
    }
  }

  Future<GpsLog?> getLog(DateTime date) async {
    try {
      final db = await _db;
      final rows = await db.query(
        'gps_sessions',
        where: 'date = ?',
        whereArgs: [date.toIso8601String().substring(0, 10)],
        orderBy: 'started_at ASC',
      );
      if (rows.isEmpty) return null;
      return GpsLog(date: date, sessions: rows.map(_rowToSession).toList());
    } catch (e) {
      log('MapLocalSource getLog failed: $e', name: 'MapLocalSource');
      return null;
    }
  }

  Future<List<GpsSession>> getUnsyncedSessions() async {
    try {
      final db = await _db;
      final rows = await db.query(
        'gps_sessions',
        where: 'synced = ?',
        whereArgs: [0],
      );
      return rows.map(_rowToSession).toList();
    } catch (e) {
      log(
        'MapLocalSource getUnsyncedSessions failed: $e',
        name: 'MapLocalSource',
      );
      return [];
    }
  }

  Future<void> insertSyncedSessions(
    DateTime date,
    List<GpsSession> sessions,
  ) async {
    try {
      final db = await _db;
      final batch = db.batch();
      for (final session in sessions) {
        batch.insert('gps_sessions', {
          'backend_id': session.backendId,
          'date': date.toIso8601String().substring(0, 10),
          'started_at': session.startedAt.toIso8601String(),
          'ended_at': session.endedAt?.toIso8601String(),
          'points': jsonEncode(session.points.map((p) => p.toJson()).toList()),
          'distance': session.distanceKm,
          'synced': 1,
        }, conflictAlgorithm: ConflictAlgorithm.ignore);
      }
      await batch.commit(noResult: true);
    } catch (e) {
      log(
        'MapLocalSource insertSyncedSessions failed: $e',
        name: 'MapLocalSource',
      );
    }
  }

  Future<void> deleteSession(int localId) async {
    try {
      final db = await _db;
      await db.delete('gps_sessions', where: 'id = ?', whereArgs: [localId]);
    } catch (e) {
      log('MapLocalSource deleteSession failed: $e', name: 'MapLocalSource');
    }
  }

  Future<void> deleteSessionsByDate(DateTime date) async {
    try {
      final db = await _db;
      await db.delete(
        'gps_sessions',
        where: 'date = ?',
        whereArgs: [date.toIso8601String().substring(0, 10)],
      );
    } catch (e) {
      log(
        'MapLocalSource deleteSessionsByDate failed: $e',
        name: 'MapLocalSource',
      );
    }
  }

  Future<void> deleteOldSessions() async {
    try {
      final db = await _db;
      final cutoff = DateTime.now()
          .subtract(const Duration(days: 30))
          .toIso8601String()
          .substring(0, 10);
      await db.delete('gps_sessions', where: 'date < ?', whereArgs: [cutoff]);
    } catch (e) {
      log(
        'MapLocalSource deleteOldSessions failed: $e',
        name: 'MapLocalSource',
      );
    }
  }

  GpsSession _rowToSession(Map<String, dynamic> row) {
    return GpsSession(
      localId: row['id'] as int,
      backendId: row['backend_id'] as int?,
      startedAt: DateTime.parse(row['started_at'] as String),
      endedAt: row['ended_at'] != null
          ? DateTime.parse(row['ended_at'] as String)
          : null,
      points: (jsonDecode(row['points'] as String) as List)
          .map((p) => GpsPoint.fromJson(p as Map<String, dynamic>))
          .toList(),
      distanceKm: (row['distance'] as num).toDouble(),
    );
  }
}
