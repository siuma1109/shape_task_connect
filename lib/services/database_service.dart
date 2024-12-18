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
    await db.transaction((txn) async {
      // Create tables first
      await _createTables(txn);

      // Generate demo data with custom quantities
      await DemoData.generateData(
        txn,
        userCount: 5, // Generate 5 users
        tasksPerUser: 3, // Each user creates 3 tasks
        commentsPerTask: 2, // Each task has 2 comments
        collaboratorsPerTask: 2, // Each task has 2 collaborators
      );
    });
  }

  Future<void> _createTables(Transaction txn) async {
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
        due_date DATETIME NOT NULL,
        completed INTEGER DEFAULT 0,
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
  }
}
