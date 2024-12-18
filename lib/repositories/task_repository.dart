import 'package:sqflite/sqflite.dart';
import '../models/task_item.dart';
import '../services/database_service.dart';

class TaskRepository {
  final DatabaseService _databaseService;

  TaskRepository(this._databaseService);

  // Create
  Future<int> createTask(TaskItem task) async {
    try {
      final db = await _databaseService.database;
      await db.insert('tasks', task.toMap());
      return task.id;
    } catch (e) {
      rethrow;
    }
  }

  // Read
  Future<List<TaskItem>> getAllTasks() async {
    final db = await _databaseService.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'tasks',
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
        'created_at': task.createdAt.millisecondsSinceEpoch,
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

  // Get tasks by user ID
  Future<List<TaskItem>> getTasksByUser(int userId) async {
    final db = await _databaseService.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'tasks',
      where: 'created_by = ?',
      whereArgs: [userId],
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

  Future<List<TaskItem>> getTasks() async {
    final db = await _databaseService.database;
    final List<Map<String, dynamic>> maps = await db.query('tasks');
    return List.generate(maps.length, (i) => TaskItem.fromMap(maps[i]));
  }
}
