import '../models/user.dart';
import '../services/database_service.dart';
import 'package:sqflite/sqflite.dart';

class UserRepository {
  final DatabaseService _databaseService;

  UserRepository(this._databaseService);

  Future<bool> createUser(User user) async {
    try {
      final db = await _databaseService.database;
      await db.insert(
        'users',
        user.toMap(),
        conflictAlgorithm: ConflictAlgorithm.abort,
      );
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<User?> getUserByEmail(String email) async {
    final db = await _databaseService.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: [email],
    );

    if (maps.isEmpty) return null;
    return User.fromMap(maps.first);
  }

  Future<bool> validateUser(String email, String password) async {
    final db = await _databaseService.database;
    final List<Map<String, dynamic>> users = await db.query(
      'users',
      where: 'email = ? AND password = ?',
      whereArgs: [email, password],
    );
    return users.isNotEmpty;
  }
}
