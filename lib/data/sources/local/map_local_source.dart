import 'dart:convert';
import 'dart:developer';
import 'package:conquest/data/models/gps_model.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class MapLocalSource {
  static final MapLocalSource _instance = MapLocalSource._internal();
  factory MapLocalSource() => _instance;
  MapLocalSource._internal();

  Database? _db;

  Future<Database> get _database async {
    _db ??= await _initDb();
    return _db!;
  }

  Future<Database> _initDb() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'conquest_map.db');
    return openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE gps_logs (
            date TEXT PRIMARY KEY,
            sessions TEXT NOT NULL,
            synced INTEGER NOT NULL DEFAULT 0
          )
        ''');
      },
    );
  }

  Future<void> upsertLog(DateTime date, List<GpsSession> sessions) async {
    try {
      final db = await _database;
      await db.insert('gps_logs', {
        'date': date.toIso8601String().substring(0, 10),
        'sessions': jsonEncode(sessions.map((s) => s.toJson()).toList()),
        'synced': 0,
      }, conflictAlgorithm: ConflictAlgorithm.replace);
    } catch (e) {
      log('MapLocalSource upsertLog failed: $e', name: 'MapLocalSource');
    }
  }

  Future<void> upsertSyncedLog(DateTime date, List<GpsSession> sessions) async {
    try {
      final db = await _database;
      await db.insert('gps_logs', {
        'date': date.toIso8601String().substring(0, 10),
        'sessions': jsonEncode(sessions.map((s) => s.toJson()).toList()),
        'synced': 1,
      }, conflictAlgorithm: ConflictAlgorithm.replace);
    } catch (e) {
      log('MapLocalSource upsertSyncedLog failed: $e', name: 'MapLocalSource');
    }
  }

  Future<void> markSynced(DateTime date) async {
    try {
      final db = await _database;
      await db.update(
        'gps_logs',
        {'synced': 1},
        where: 'date = ?',
        whereArgs: [date.toIso8601String().substring(0, 10)],
      );
    } catch (e) {
      log('MapLocalSource markSynced failed: $e', name: 'MapLocalSource');
    }
  }

  Future<GpsLog?> getLog(DateTime date) async {
    try {
      final db = await _database;
      final rows = await db.query(
        'gps_logs',
        where: 'date = ?',
        whereArgs: [date.toIso8601String().substring(0, 10)],
      );
      if (rows.isEmpty) return null;
      final sessions = (jsonDecode(rows.first['sessions'] as String) as List)
          .map((s) => GpsSession.fromJson(s as Map<String, dynamic>))
          .toList();
      return GpsLog(date: date, sessions: sessions);
    } catch (e) {
      log('MapLocalSource getLog failed: $e', name: 'MapLocalSource');
      return null;
    }
  }

  Future<List<GpsLog>> getUnsyncedLogs() async {
    try {
      final db = await _database;
      final rows = await db.query(
        'gps_logs',
        where: 'synced = ?',
        whereArgs: [0],
      );
      return rows.map((row) {
        final date = DateTime.parse(row['date'] as String);
        final sessions = (jsonDecode(row['sessions'] as String) as List)
            .map((s) => GpsSession.fromJson(s as Map<String, dynamic>))
            .toList();
        return GpsLog(date: date, sessions: sessions);
      }).toList();
    } catch (e) {
      log('MapLocalSource getUnsyncedLogs failed: $e', name: 'MapLocalSource');
      return [];
    }
  }

  Future<void> deleteLog(DateTime date) async {
    try {
      final db = await _database;
      await db.delete(
        'gps_logs',
        where: 'date = ?',
        whereArgs: [date.toIso8601String().substring(0, 10)],
      );
    } catch (e) {
      log('MapLocalSource deleteLog failed: $e', name: 'MapLocalSource');
    }
  }

  Future<void> deleteOldLogs() async {
    try {
      final db = await _database;
      final cutoff = DateTime.now()
          .subtract(const Duration(days: 30))
          .toIso8601String()
          .substring(0, 10);
      await db.delete('gps_logs', where: 'date < ?', whereArgs: [cutoff]);
    } catch (e) {
      log('MapLocalSource deleteOldLogs failed: $e', name: 'MapLocalSource');
    }
  }

  Future<void> close() async {
    await _db?.close();
    _db = null;
  }
}
