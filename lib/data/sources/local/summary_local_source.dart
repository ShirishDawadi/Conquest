import 'dart:developer';
import 'package:conquest/core/database/app_database.dart';
import 'package:conquest/data/models/quest_model.dart';
import 'package:conquest/data/models/reward_model.dart';
import 'package:sqflite/sqflite.dart';

class SummaryLocalSource {
  static final SummaryLocalSource _instance = SummaryLocalSource._internal();
  factory SummaryLocalSource() => _instance;
  SummaryLocalSource._internal();

  final _appDb = AppDatabase();

  Future<Database> get _db async => _appDb.database;

  String _fmt(DateTime date) => date.toIso8601String().substring(0, 10);

  Future<void> upsertQuest({
    required DateTime date,
    required QuestObjectModel object1,
    required QuestObjectModel object2,
    required bool object1Completed,
    required bool object2Completed,
  }) async {
    try {
      final db = await _db;
      await db.insert('daily_quests', {
        'date': _fmt(date),
        'object1_id': object1.id,
        'object1_label': object1.label,
        'object1_difficulty': object1.difficulty,
        'object1_image_url': object1.imageUrl,
        'object1_completed': object1Completed ? 1 : 0,
        'object2_id': object2.id,
        'object2_label': object2.label,
        'object2_difficulty': object2.difficulty,
        'object2_image_url': object2.imageUrl,
        'object2_completed': object2Completed ? 1 : 0,
      }, conflictAlgorithm: ConflictAlgorithm.replace);
    } catch (e) {
      log(
        'SummaryLocalSource upsertQuest failed: $e',
        name: 'SummaryLocalSource',
      );
    }
  }

  Future<void> markObjectCompleted({
    required DateTime date,
    required int objectId,
  }) async {
    try {
      final db = await _db;
      final dateStr = _fmt(date);

      final rows = await db.query(
        'daily_quests',
        where: 'date = ?',
        whereArgs: [dateStr],
      );
      if (rows.isEmpty) return;

      final row = rows.first;
      final updates = <String, dynamic>{};

      if (row['object1_id'] == objectId) {
        updates['object1_completed'] = 1;
      }
      if (row['object2_id'] == objectId) {
        updates['object2_completed'] = 1;
      }

      if (updates.isEmpty) return;

      await db.update(
        'daily_quests',
        updates,
        where: 'date = ?',
        whereArgs: [dateStr],
      );
    } catch (e) {
      log(
        'SummaryLocalSource markObjectCompleted failed: $e',
        name: 'SummaryLocalSource',
      );
    }
  }

  Future<void> updateObjectImage({
    required DateTime date,
    required int objectId,
    required String imageUrl,
  }) async {
    try {
      final db = await _db;
      final dateStr = _fmt(date);

      final rows = await db.query(
        'daily_quests',
        where: 'date = ?',
        whereArgs: [dateStr],
      );
      if (rows.isEmpty) return;

      final row = rows.first;
      final updates = <String, dynamic>{};

      if (row['object1_id'] == objectId) {
        updates['object1_image_url'] = imageUrl;
      }
      if (row['object2_id'] == objectId) {
        updates['object2_image_url'] = imageUrl;
      }

      if (updates.isEmpty) return;

      await db.update(
        'daily_quests',
        updates,
        where: 'date = ?',
        whereArgs: [dateStr],
      );
    } catch (e) {
      log(
        'SummaryLocalSource updateObjectImage failed: $e',
        name: 'SummaryLocalSource',
      );
    }
  }

  Future<Map<String, dynamic>?> getQuest(DateTime date) async {
    try {
      final db = await _db;
      final rows = await db.query(
        'daily_quests',
        where: 'date = ?',
        whereArgs: [_fmt(date)],
      );
      return rows.isEmpty ? null : rows.first;
    } catch (e) {
      log('SummaryLocalSource getQuest failed: $e', name: 'SummaryLocalSource');
      return null;
    }
  }

  Future<void> insertRewards(
    DateTime date,
    List<UserRewardModel> rewards,
  ) async {
    if (rewards.isEmpty) return;
    try {
      final db = await _db;
      final batch = db.batch();
      for (final reward in rewards) {
        batch.insert('user_rewards', reward.toDbMap(date));
      }
      await batch.commit(noResult: true);
    } catch (e) {
      log(
        'SummaryLocalSource insertRewards failed: $e',
        name: 'SummaryLocalSource',
      );
    }
  }

  Future<List<UserRewardModel>> getRewards(DateTime date) async {
    try {
      final db = await _db;
      final rows = await db.query(
        'user_rewards',
        where: 'date = ?',
        whereArgs: [_fmt(date)],
      );
      return rows.map((r) => UserRewardModel.fromDb(r)).toList();
    } catch (e) {
      log(
        'SummaryLocalSource getRewards failed: $e',
        name: 'SummaryLocalSource',
      );
      return [];
    }
  }
}
