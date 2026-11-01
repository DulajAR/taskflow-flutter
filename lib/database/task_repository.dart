import '../models/task.dart';
import 'database_helper.dart';

class TaskRepository {
  final DatabaseHelper _databaseHelper = DatabaseHelper.instance;

  Future<int> addTask(Task task) async {
    final db = await _databaseHelper.database;

    return await db.insert('tasks', task.toMap()..remove('id'));
  }

  Future<List<Task>> getAllTasks() async {
    final db = await _databaseHelper.database;

    final result = await db.query('tasks', orderBy: 'createdAt DESC');

    return result.map((map) => Task.fromMap(map)).toList();
  }

  Future<int> updateTask(Task task) async {
    final db = await _databaseHelper.database;

    return await db.update(
      'tasks',
      task.toMap()..remove('id'),
      where: 'id = ?',
      whereArgs: [task.id],
    );
  }

  Future<int> deleteTask(int id) async {
    final db = await _databaseHelper.database;

    return await db.delete('tasks', where: 'id = ?', whereArgs: [id]);
  }
}
