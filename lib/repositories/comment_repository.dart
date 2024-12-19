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
  Future<List<Comment>> getCommentsByTask(int taskId) async {
    final db = await _databaseService.database;

    // Join comments with users table to get user data
    final List<Map<String, dynamic>> results = await db.rawQuery('''
      SELECT 
        c.*,
        u.id as user_id,
        u.username as user_name,
        u.email as user_email
      FROM comments c
      LEFT JOIN users u ON c.user_id = u.id
      WHERE c.task_id = ?
      ORDER BY c.created_at DESC
    ''', [taskId]);

    return results.map((result) {
      // Create a user map from the joined data
      final userMap = {
        'id': result['user_id'],
        'username': result['user_name'],
        'email': result['user_email'],
      };

      // Create the comment map
      final commentMap = {
        'id': result['id'],
        'task_id': result['task_id'],
        'user_id': result['user_id'],
        'content': result['content'],
        'created_at': result['created_at'],
        'latitude': result['latitude'],
        'longitude': result['longitude'],
        'address': result['address'],
        'photo_path': result['photo_path'],
        'user': userMap,
      };

      return Comment.fromMap(commentMap);
    }).toList();
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
  Future<int> deleteTaskComments(int taskId) async {
    final db = await _databaseService.database;
    return await db.delete(
      'comments',
      where: 'task_id = ?',
      whereArgs: [taskId],
    );
  }

  // Count comments for a task
  Future<int> countTaskComments(int taskId) async {
    final db = await _databaseService.database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM comments WHERE task_id = ?',
      [taskId],
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }
}
