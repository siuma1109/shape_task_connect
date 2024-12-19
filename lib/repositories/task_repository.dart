import 'package:shape_task_connect/models/user.dart';
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

    final List<Map<String, dynamic>> maps = await db.rawQuery('''
      SELECT 
        t.*,
        u.id as user_id,
        u.username as user_name,
        u.email as user_email
      FROM tasks t
      LEFT JOIN users u ON t.created_by = u.id
      ORDER BY t.created_at DESC
    ''');

    return maps.map((map) {
      // Create a user map from the joined data
      final userMap = {
        'id': map['user_id'],
        'username': map['user_name'],
        'email': map['user_email'],
      };

      // Create the comment map
      final taskMap = {
        'id': map['id'],
        'title': map['title'],
        'description': map['description'],
        'due_date': map['due_date'],
        'completed': map['completed'],
        'created_by': map['created_by'],
        'created_at': map['created_at'],
        'user': userMap,
      };

      return TaskItem.fromMap(taskMap);
    }).toList();
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
        'due_date': task.dueDate.toString(),
        'completed': task.completed ? 1 : 0,
      },
      where: 'id = ?',
      whereArgs: [task.id],
    );
  }

  // Delete
  Future<int> deleteTask(int id) async {
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

  // Get tasks by user ID (both created and joined tasks)
  Future<List<TaskItem>> getTasksByUser(int userId) async {
    final db = await _databaseService.database;

    final List<Map<String, dynamic>> maps = await db.rawQuery('''
      SELECT 
        t.*,
        u.id as user_id,
        u.username as user_name,
        u.email as user_email
      FROM tasks t
      LEFT JOIN users u ON t.created_by = u.id
      WHERE t.created_by = ?
        OR t.id IN (
          SELECT task_id 
          FROM task_users 
          WHERE user_id = ?
        )
      ORDER BY t.created_at DESC
    ''', [userId, userId]);

    return maps.map((map) {
      // Create a user map from the joined data
      final userMap = {
        'id': map['user_id'],
        'username': map['user_name'],
        'email': map['user_email'],
      };

      // Create the task map
      final taskMap = {
        'id': map['id'],
        'title': map['title'],
        'description': map['description'],
        'created_by': map['created_by'],
        'created_at': map['created_at'],
        'due_date': map['due_date'],
        'completed': map['completed'],
        'user': userMap,
      };

      return TaskItem.fromMap(taskMap);
    }).toList();
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

  Future<List<TaskItem>> getTasksByUserAndDueDateRange(
      int? userId, DateTime startDate, DateTime endDate) async {
    final Database db = await _databaseService.database;

    final List<Map<String, dynamic>> maps = await db.rawQuery('''
      SELECT 
        t.*,
        u.id as user_id,
        u.username as user_name,
        u.email as user_email
      FROM tasks t
      LEFT JOIN users u ON t.created_by = u.id
      WHERE (t.created_by = ? 
        OR t.id IN (
          SELECT task_id 
          FROM task_users 
          WHERE user_id = ?
        ))
      AND t.due_date BETWEEN ? AND ?
      ORDER BY t.due_date DESC
    ''', [userId, userId, startDate.toString(), endDate.toString()]);

    return maps.map((map) {
      // Create a user map from the joined data
      final userMap = {
        'id': map['user_id'],
        'username': map['user_name'],
        'email': map['user_email'],
      };

      // Create the task map
      final taskMap = {
        'id': map['id'],
        'title': map['title'],
        'description': map['description'],
        'created_by': map['created_by'],
        'created_at': map['created_at'],
        'due_date': map['due_date'],
        'completed': map['completed'],
        'user': userMap,
      };

      return TaskItem.fromMap(taskMap);
    }).toList();
  }

  Future<Map<DateTime, int>> getTaskCountsByDateRange(
    int? userId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    final Database db = await _databaseService.database;

    final List<Map<String, dynamic>> maps = await db.rawQuery('''
      SELECT t.* 
      FROM tasks t
      WHERE (t.created_by = ? 
        OR t.id IN (
          SELECT task_id 
          FROM task_users 
          WHERE user_id = ?
        ))
      AND t.due_date BETWEEN ? AND ?
    ''', [userId, userId, startDate.toString(), endDate.toString()]);

    final taskCounts = <DateTime, int>{};

    for (final map in maps) {
      final dueDate = DateTime.parse(map['due_date']);
      final date = DateTime(dueDate.year, dueDate.month, dueDate.day);
      taskCounts[date] = (taskCounts[date] ?? 0) + 1;
    }

    return taskCounts;
  }
}
