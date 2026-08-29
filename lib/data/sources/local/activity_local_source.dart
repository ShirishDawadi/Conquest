import 'dart:developer';
import 'package:conquest/core/database/app_database.dart';
import 'package:conquest/data/models/activity_model.dart';
import 'package:sqflite/sqflite.dart';

class ActivityLocalSource {
  static final ActivityLocalSource _instance = ActivityLocalSource._internal();
  factory ActivityLocalSource() => _instance;
  ActivityLocalSource._internal();

  final _appDb = AppDatabase();

  Future<Database> get _db async => _appDb.database;

  String _fmt(DateTime date) => date.toIso8601String().substring(0, 10);

  Future<void> upsertLocalSteps(DateTime date, int steps, {int? goal}) async {
    try {
      final db = await _db;
      final existing = await db.query(
        'activity_logs',
        where: 'date = ?',
        whereArgs: [_fmt(date)],
      );

      await db.insert('activity_logs', {
        'date': _fmt(date),
        'steps_achieved': steps,
        'steps_goal':
            goal ??
            (existing.isNotEmpty ? existing.first['steps_goal'] as int : 0),
        'synced': 0,
      }, conflictAlgorithm: ConflictAlgorithm.replace);
    } catch (e) {
      log(
        'ActivityLocalSource upsertLocalSteps failed: $e',
        name: 'ActivityLocalSource',
      );
    }
  }

  Future<void> upsertSyncedSteps({
    required DateTime date,
    required int steps,
    required int goal,
  }) async {
    try {
      final db = await _db;
      await db.insert('activity_logs', {
        'date': _fmt(date),
        'steps_achieved': steps,
        'steps_goal': goal,
        'synced': 1,
      }, conflictAlgorithm: ConflictAlgorithm.replace);
    } catch (e) {
      log(
        'ActivityLocalSource upsertSyncedSteps failed: $e',
        name: 'ActivityLocalSource',
      );
    }
  }

  Future<void> markSynced(DateTime date) async {
    try {
      final db = await _db;
      await db.update(
        'activity_logs',
        {'synced': 1},
        where: 'date = ?',
        whereArgs: [_fmt(date)],
      );
    } catch (e) {
      log(
        'ActivityLocalSource markSynced failed: $e',
        name: 'ActivityLocalSource',
      );
    }
  }

  Future<Map<String, dynamic>?> getLog(DateTime date) async {
    try {
      final db = await _db;
      final rows = await db.query(
        'activity_logs',
        where: 'date = ?',
        whereArgs: [_fmt(date)],
      );
      return rows.isEmpty ? null : rows.first;
    } catch (e) {
      log('ActivityLocalSource getLog failed: $e', name: 'ActivityLocalSource');
      return null;
    }
  }

  Future<List<Map<String, dynamic>>> getRange(
    DateTime start,
    DateTime end,
  ) async {
    try {
      final db = await _db;
      return await db.query(
        'activity_logs',
        where: 'date BETWEEN ? AND ?',
        whereArgs: [_fmt(start), _fmt(end)],
        orderBy: 'date ASC',
      );
    } catch (e) {
      log(
        'ActivityLocalSource getRange failed: $e',
        name: 'ActivityLocalSource',
      );
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getUnsyncedLogs() async {
    try {
      final db = await _db;
      return await db.query(
        'activity_logs',
        where: 'synced = ?',
        whereArgs: [0],
      );
    } catch (e) {
      log(
        'ActivityLocalSource getUnsyncedLogs failed: $e',
        name: 'ActivityLocalSource',
      );
      return [];
    }
  }

  Future<void> upsertStatsDays(List<StepsStatsDay> days) async {
    try {
      final db = await _db;
      final today = DateTime.now().toIso8601String().substring(0, 10);
      final batch = db.batch();

      for (final day in days) {
        if (day.date == today) continue;

        batch.insert('activity_logs', {
          'date': day.date,
          'steps_achieved': day.steps,
          'steps_goal': day.goal,
          'synced': 1,
        }, conflictAlgorithm: ConflictAlgorithm.replace);
      }

      await batch.commit(noResult: true);
    } catch (e) {
      log(
        'ActivityLocalSource upsertStatsDays failed: $e',
        name: 'ActivityLocalSource',
      );
    }
  }

  Future<bool> hasFullRange(DateTime start, DateTime end) async {
    try {
      final rows = await getRange(start, end);
      final expectedDays = end.difference(start).inDays + 1;
      final today = DateTime.now().toIso8601String().substring(0, 10);
      final hasToday = rows.any((r) => r['date'] == today);
      final endStr = _fmt(end);

      final expectedStored = (endStr == today && !hasToday)
          ? expectedDays - 1
          : expectedDays;

      return rows.length >= expectedStored;
    } catch (e) {
      log(
        'ActivityLocalSource hasFullRange failed: $e',
        name: 'ActivityLocalSource',
      );
      return false;
    }
  }
}
