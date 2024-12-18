import '../models/user.dart';
import '../services/database_service.dart';
import 'package:sqflite/sqflite.dart';

class UserRepository {
  final DatabaseService _databaseService;

  UserRepository(this._databaseService);

  // Create
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

  // Read
  Future<List<User>> getAllUsers() async {
    final db = await _databaseService.database;
    final List<Map<String, dynamic>> maps = await db.query('users');
    return List.generate(maps.length, (i) => User.fromMap(maps[i]));
  }

  Future<User?> getUser(int id) async {
    final db = await _databaseService.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'users',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isEmpty) return null;
    return User.fromMap(maps.first);
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

  Future<User?> getUserByUsername(String username) async {
    final db = await _databaseService.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'users',
      where: 'username = ?',
      whereArgs: [username],
    );

    if (maps.isEmpty) return null;
    return User.fromMap(maps.first);
  }

  // Update
  Future<bool> updateUser(User user) async {
    try {
      final db = await _databaseService.database;
      final count = await db.update(
        'users',
        user.toMap(),
        where: 'id = ?',
        whereArgs: [user.id],
      );
      return count > 0;
    } catch (e) {
      return false;
    }
  }

  // Delete
  Future<bool> deleteUser(int id) async {
    try {
      final db = await _databaseService.database;

      // First delete all tasks created by this user
      await db.delete(
        'tasks',
        where: 'created_by = ?',
        whereArgs: [id],
      );

      // Then delete the user
      final count = await db.delete(
        'users',
        where: 'id = ?',
        whereArgs: [id],
      );
      return count > 0;
    } catch (e) {
      return false;
    }
  }

  // Validation methods
  Future<bool> validateUser(String email, String password) async {
    final db = await _databaseService.database;
    final List<Map<String, dynamic>> users = await db.query(
      'users',
      where: 'email = ? AND password = ?',
      whereArgs: [email, password],
    );
    return users.isNotEmpty;
  }

  Future<bool> isEmailTaken(String email) async {
    final user = await getUserByEmail(email);
    return user != null;
  }

  Future<bool> isUsernameTaken(String username) async {
    final user = await getUserByUsername(username);
    return user != null;
  }

  // Search users by keyword (username or email)
  Future<List<User>> searchUsers(String keyword) async {
    final db = await _databaseService.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'users',
      where: 'username LIKE ? OR email LIKE ?',
      whereArgs: ['%$keyword%', '%$keyword%'],
    );

    return List.generate(maps.length, (i) => User.fromMap(maps[i]));
  }
}
