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
      version: 2,
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
        await db.execute(_objectCapturesTableSql);
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        log(
          'AppDatabase upgrade from $oldVersion to $newVersion',
          name: 'AppDatabase',
        );
        if (oldVersion < 2) {
          await db.execute(_objectCapturesTableSql);
        }
      },
    );
  }

  static const _objectCapturesTableSql = '''
    CREATE TABLE object_images (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      quest_id INTEGER,
      object_id INTEGER NOT NULL,
      image_path TEXT NOT NULL,
      latitude REAL,
      longitude REAL,
      created_at TEXT NOT NULL
    )
  ''';

  Future<void> deleteDb() async {
    await close();
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'conquest.db');
    await deleteDatabase(path);
  }

  Future<void> close() async {
    await _db?.close();
    _db = null;
  }
}