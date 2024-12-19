import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
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
          password TEXT,
          created_at DATETIME DEFAULT CURRENT_TIMESTAMP
        )
      ''');

      // Create tasks table
      await txn.execute('''
        CREATE TABLE tasks(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          title TEXT NOT NULL,
          description TEXT NOT NULL,
          created_by INTEGER NOT NULL,
          created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
          FOREIGN KEY (created_by) REFERENCES users (id)
        )
      ''');

      // Create task_users table for users joining tasks
      await txn.execute('''
        CREATE TABLE task_users(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          task_id INTEGER NOT NULL,
          user_id INTEGER NOT NULL,
          created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
          FOREIGN KEY (task_id) REFERENCES tasks (id) ON DELETE CASCADE,
          FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE,
          UNIQUE(task_id, user_id)
        )
      ''');

      // Create comments table
      await txn.execute('''
        CREATE TABLE comments(
          id INTEGER PRIMARY KEY,
          task_id INTEGER NOT NULL,
          user_id INTEGER NOT NULL,
          content TEXT NOT NULL,
          created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
          latitude REAL,
          longitude REAL,
          address TEXT,
          photo_path TEXT
        )
      ''');

      // Insert test user
      await txn.insert('users', {
        'email': 'test@example.com',
        'username': 'testuser',
        'password': 'password123',
      });
    });
  }
}
