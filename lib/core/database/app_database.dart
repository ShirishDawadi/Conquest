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
        await db.execute(_gpsSessionsTableSql);
        await db.execute(_objectCapturesTableSql);
        await db.execute(_dailyQuestsTableSql);
        await db.execute(_activityLogsTableSql);
        await db.execute(_userRewardsTableSql);
      },
    );
  }

  static const _gpsSessionsTableSql = '''
    CREATE TABLE gps_sessions (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      backend_id INTEGER,
      date TEXT NOT NULL,
      started_at TEXT NOT NULL,
      ended_at TEXT,
      points TEXT NOT NULL,
      distance REAL NOT NULL DEFAULT 0,
      furthest_distance REAL NOT NULL DEFAULT 0,
      synced INTEGER NOT NULL DEFAULT 0
    )
  ''';

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

  static const _dailyQuestsTableSql = '''
    CREATE TABLE daily_quests (
      date TEXT PRIMARY KEY,
      object1_id INTEGER,
      object1_label TEXT,
      object1_difficulty TEXT,
      object1_image_url TEXT,
      object1_completed INTEGER NOT NULL DEFAULT 0,
      object2_id INTEGER,
      object2_label TEXT,
      object2_difficulty TEXT,
      object2_image_url TEXT,
      object2_completed INTEGER NOT NULL DEFAULT 0
    )
  ''';

  static const _activityLogsTableSql = '''
    CREATE TABLE activity_logs (
      date TEXT PRIMARY KEY,
      steps_achieved INTEGER NOT NULL DEFAULT 0,
      steps_goal INTEGER NOT NULL DEFAULT 0,
      synced INTEGER NOT NULL DEFAULT 0
    )
  ''';

  static const _userRewardsTableSql = '''
  CREATE TABLE user_rewards (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    date TEXT NOT NULL,
    action_type TEXT NOT NULL,
    tier TEXT,
    xp_earned INTEGER NOT NULL DEFAULT 0,
    points_earned INTEGER NOT NULL DEFAULT 0
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
