import 'package:sqflite/sqflite.dart';
import '../models/comment.dart';
import '../services/database_service.dart';

class CommentRepository {
  final DatabaseService _databaseService;

  CommentRepository(this._databaseService);

  // Create
  Future<int> createComment(Comment comment) async {
    final db = await _databaseService.database;
    return await db.insert(
      'comments',
      comment.toMap(),
      conflictAlgorithm: ConflictAlgorithm.abort,
    );
  }

  // Read
  Future<List<Comment>> getCommentsByTask(String taskId) async {
    final db = await _databaseService.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'comments',
      where: 'task_id = ?',
      whereArgs: [taskId],
      orderBy: 'created_at DESC',
    );

    return List.generate(maps.length, (i) => Comment.fromMap(maps[i]));
  }

  Future<List<Comment>> getCommentsByUser(int userId) async {
    final db = await _databaseService.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'comments',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'created_at DESC',
    );

    return List.generate(maps.length, (i) => Comment.fromMap(maps[i]));
  }

  Future<Comment?> getComment(int id) async {
    final db = await _databaseService.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'comments',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isEmpty) return null;
    return Comment.fromMap(maps.first);
  }

  // Update
  Future<int> updateComment(Comment comment) async {
    final db = await _databaseService.database;
    return await db.update(
      'comments',
      comment.toMap(),
      where: 'id = ?',
      whereArgs: [comment.id],
    );
  }

  // Delete
  Future<int> deleteComment(int id) async {
    final db = await _databaseService.database;
    return await db.delete(
      'comments',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Delete all comments for a task
  Future<int> deleteTaskComments(String taskId) async {
    final db = await _databaseService.database;
    return await db.delete(
      'comments',
      where: 'task_id = ?',
      whereArgs: [taskId],
    );
  }

  // Count comments for a task
  Future<int> countTaskComments(String taskId) async {
    final db = await _databaseService.database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM comments WHERE task_id = ?',
      [taskId],
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }
}
