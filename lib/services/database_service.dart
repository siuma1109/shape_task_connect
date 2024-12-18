import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/task_item.dart';
import '../utils/demo_data.dart';

class DatabaseService {
  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'auth_database.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // Create tables
    await db.transaction((txn) async {
      // Create users table
      await txn.execute('''
        CREATE TABLE users(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          email TEXT UNIQUE,
          username TEXT,
          password TEXT
        )
      ''');

      // Create tasks table
      await txn.execute('''
        CREATE TABLE tasks(
          id TEXT PRIMARY KEY,
          title TEXT NOT NULL,
          description TEXT NOT NULL,
          created_by INTEGER NOT NULL,
          created_at INTEGER NOT NULL,
          FOREIGN KEY (created_by) REFERENCES users (id)
        )
      ''');

      // Insert test user
      await txn.insert('users', {
        'email': 'test@example.com',
        'username': 'testuser',
        'password': 'password123',
      });

      // Insert demo tasks
      final tasks = DemoData.generateTasks(5);
      for (var task in tasks) {
        await txn.insert('tasks', {
          'id': task.id,
          'title': task.title,
          'description': task.description,
          'created_by': task.createdBy,
          'created_at': task.createdAt.millisecondsSinceEpoch,
        });
      }
    });
  }

  // Task CRUD Operations
  Future<String> insertTask(TaskItem task) async {
    final db = await database;
    await db.insert('tasks', {
      'id': task.id,
      'title': task.title,
      'description': task.description,
      'created_by': task.createdBy,
      'created_at': task.createdAt.millisecondsSinceEpoch,
    });
    return task.id;
  }

  Future<List<TaskItem>> getAllTasks() async {
    final db = await database;
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

  Future<TaskItem?> getTask(String id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'tasks',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return TaskItem(
        id: maps[0]['id'],
        title: maps[0]['title'],
        description: maps[0]['description'],
        createdBy: maps[0]['created_by'],
        createdAt: DateTime.fromMillisecondsSinceEpoch(maps[0]['created_at']),
      );
    }
    return null;
  }

  Future<int> updateTask(TaskItem task) async {
    final db = await database;
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

  Future<int> deleteTask(String id) async {
    final db = await database;
    return await db.delete(
      'tasks',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
