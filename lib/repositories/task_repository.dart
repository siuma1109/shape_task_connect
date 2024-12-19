import 'package:sqflite/sqflite.dart';
import '../models/task_item.dart';
import '../services/database_service.dart';

class TaskRepository {
  final DatabaseService _databaseService;

  TaskRepository(this._databaseService);

  Future<int> createTask(TaskItem task) async {
    final db = await _databaseService.database;
    return await db.insert(
      'tasks',
      task.toMap(),
      conflictAlgorithm: ConflictAlgorithm.abort,
    );
  }

  Future<bool> joinTask(int taskId, int userId) async {
    final db = await _databaseService.database;
    try {
      await db.insert(
        'task_users',
        {
          'task_id': taskId,
          'user_id': userId,
          'created_at': DateTime.now().toIso8601String(),
        },
        conflictAlgorithm: ConflictAlgorithm.abort,
      );
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<List<TaskItem>> getTasks() async {
    final db = await _databaseService.database;
    final List<Map<String, dynamic>> maps = await db.query('tasks');
    return List.generate(maps.length, (i) => TaskItem.fromMap(maps[i]));
  }

  // Read
  Future<List<TaskItem>> getAllTasks() async {
    final db = await _databaseService.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'tasks',
      orderBy: 'created_at DESC',
    );
    return List.generate(maps.length, (i) => TaskItem.fromMap(maps[i]));
  }

  Future<TaskItem?> getTask(int id) async {
    final db = await _databaseService.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'tasks',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isEmpty) return null;
    return TaskItem.fromMap(maps.first);
  }

  // Update
  Future<int> updateTask(TaskItem task) async {
    final db = await _databaseService.database;
    return await db.update(
      'tasks',
      {
        'title': task.title,
        'description': task.description,
        'created_by': task.createdBy,
        'created_at': task.createdAt?.millisecondsSinceEpoch,
      },
      where: 'id = ?',
      whereArgs: [task.id],
    );
  }

  // Delete
  Future<int> deleteTask(String id) async {
    final db = await _databaseService.database;
    return await db.delete(
      'tasks',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Search tasks by keyword
  Future<List<TaskItem>> searchTasks(String keyword) async {
    final db = await _databaseService.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'tasks',
      where: 'title LIKE ? OR description LIKE ?',
      whereArgs: ['%$keyword%', '%$keyword%'],
      orderBy: 'created_at DESC',
    );

    return List.generate(maps.length, (i) => TaskItem.fromMap(maps[i]));
  }

  // Get tasks by user ID
  Future<List<TaskItem>> getTasksByUser(int userId) async {
    final db = await _databaseService.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'tasks',
      where: 'created_by = ?',
      whereArgs: [userId],
      orderBy: 'created_at DESC',
    );

    return List.generate(maps.length, (i) => TaskItem.fromMap(maps[i]));
  }

  Future<bool> isUserJoined(int taskId, int userId) async {
    final db = await _databaseService.database;
    final result = await db.query(
      'task_users',
      where: 'task_id = ? AND user_id = ?',
      whereArgs: [taskId, userId],
    );
    return result.isNotEmpty;
  }

  Future<bool> leaveTask(int taskId, int userId) async {
    final db = await _databaseService.database;
    try {
      await db.delete(
        'task_users',
        where: 'task_id = ? AND user_id = ?',
        whereArgs: [taskId, userId],
      );
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<List<TaskItem>> getTasksByUserAndCreatedAtRange(
      int? userId, DateTime startDate, DateTime endDate) async {
    final Database db = await _databaseService.database;

    final List<Map<String, dynamic>> maps = await db.query(
      'tasks',
      where: 'created_by = ? AND created_at BETWEEN ? AND ?',
      whereArgs: [
        userId,
        startDate.millisecondsSinceEpoch,
        endDate.millisecondsSinceEpoch
      ],
      orderBy: 'created_at DESC',
    );

    return List.generate(maps.length, (i) {
      return TaskItem(
        id: maps[i]['id'],
        title: maps[i]['title'],
        description: maps[i]['description'],
        createdBy: maps[i]['created_by'],
        createdAt: DateTime.fromMillisecondsSinceEpoch(maps[i]['created_at']),
      );
    });
  }

  Future<Map<DateTime, int>> getTaskCountsByDateRange(
    int? userId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    final Database db = await _databaseService.database;

    final List<Map<String, dynamic>> maps = await db.query(
      'tasks',
      where: 'created_by = ? AND created_at BETWEEN ? AND ?',
      whereArgs: [
        userId,
        startDate.millisecondsSinceEpoch,
        endDate.millisecondsSinceEpoch
      ],
    );

    final taskCounts = <DateTime, int>{};

    for (final map in maps) {
      final createdAt = DateTime.fromMillisecondsSinceEpoch(map['created_at']);
      final date = DateTime(createdAt.year, createdAt.month, createdAt.day);
      taskCounts[date] = (taskCounts[date] ?? 0) + 1;
    }

    return taskCounts;
  }
}
