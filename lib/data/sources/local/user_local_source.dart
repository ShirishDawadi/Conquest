import 'package:conquest/core/database/app_database.dart';
import 'package:conquest/data/models/user_model.dart';
import 'package:sqflite/sqflite.dart';

class UserLocalSource {
  Future<UserModel?> getUser() async {
    final db = await AppDatabase().database;
    final rows = await db.query('user', limit: 1);
    if (rows.isEmpty) return null;
    return UserModel.fromMap(rows.first);
  }

  Future<void> saveUser(UserModel user) async {
    final db = await AppDatabase().database;
    await db.transaction((txn) async {
      await txn.delete('user');
      await txn.insert(
        'user',
        user.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    });
  }

  Future<void> clear() async {
    final db = await AppDatabase().database;
    await db.delete('user');
  }
}