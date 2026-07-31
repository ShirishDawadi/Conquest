import 'package:conquest/core/database/app_database.dart';

class ObjectImageLocalSource {
  static const _table = 'object_images';

  Future<int> insertPending({
    required int? questId,
    required int objectId,
    required String imagePath,
    double? latitude,
    double? longitude,
  }) async {
    final db = await AppDatabase().database;
    return db.insert(_table, {
      'quest_id': questId,
      'object_id': objectId,
      'image_path': imagePath,
      'latitude': latitude,
      'longitude': longitude,
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  Future<List<Map<String, Object?>>> getPending() async {
    final db = await AppDatabase().database;
    return db.query(_table);
  }

  Future<String?> getPendingImagePath(int objectId, {int? questId}) async {
    final db = await AppDatabase().database;
    final rows = await db.query(
      _table,
      where: questId != null ? 'object_id = ? AND quest_id = ?' : 'object_id = ?',
      whereArgs: questId != null ? [objectId, questId] : [objectId],
      orderBy: 'created_at DESC',
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return rows.first['image_path'] as String;
  }

  Future<bool> hasPending(int objectId, {int? questId}) async {
    final path = await getPendingImagePath(objectId, questId: questId);
    return path != null;
  }

  Future<void> deleteCapture(int id) async {
    final db = await AppDatabase().database;
    await db.delete(_table, where: 'id = ?', whereArgs: [id]);
  }
}