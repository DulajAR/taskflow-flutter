import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();

  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _initDB('taskflow.db');
    return _database!;
  }

  Future<Database> _initDB(String fileName) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, fileName);

    return openDatabase(
      path,
      version: 2,
      onCreate: _createDB,
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute(
            'ALTER TABLE tasks ADD COLUMN reminderMinutes '
            'INTEGER NOT NULL DEFAULT 0',
          );
        }
      },
    );
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE tasks (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        description TEXT NOT NULL,
        category TEXT NOT NULL,
        priority TEXT NOT NULL,
        dueDate TEXT,
        isCompleted INTEGER NOT NULL,
        createdAt TEXT NOT NULL,
        reminderMinutes INTEGER NOT NULL DEFAULT 0
      )
    ''');
  }

  Future<void> close() async {
    final db = await instance.database;
    await db.close();
    _database = null;
  }
}
