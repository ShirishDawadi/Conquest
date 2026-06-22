import 'dart:developer';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class AppDatabase {
  static final AppDatabase _instance = AppDatabase._internal();
  factory AppDatabase() => _instance;
  AppDatabase._internal();

  Database? _db;

  Future<Database> get database async {
    _db ??= await _initDb();
    return _db!;
  }

  Future<Database> _initDb() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'conquest.db');
    return openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE gps_sessions (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            backend_id INTEGER,
            date TEXT NOT NULL,
            started_at TEXT NOT NULL,
            ended_at TEXT,
            points TEXT NOT NULL,
            distance REAL NOT NULL DEFAULT 0,
            synced INTEGER NOT NULL DEFAULT 0
          )
        ''');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        log('AppDatabase upgrade from $oldVersion to $newVersion', name: 'AppDatabase');
      },
    );
  }

  Future<void> close() async {
    await _db?.close();
    _db = null;
  }
}