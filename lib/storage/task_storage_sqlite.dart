import 'package:sqlite3/sqlite3.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'task_storage.dart';
import '../models/tasks.dart';
import 'dart:async';

class TaskStorageSQLite implements TaskStorage {
  late Database _db;
  final _dbLock = Completer<void>();

  TaskStorageSQLite() {
    _initializeDatabase();
  }

  Future<void> _initializeDatabase() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final dbPath = path.join(directory.path, 'todo_app.db');
      _db = sqlite3.open(dbPath);
      _db.execute('''
        CREATE TABLE IF NOT EXISTS tasks (
          id TEXT PRIMARY KEY,
          title TEXT,
          description TEXT,
          deadline TEXT,
          priority INTEGER,
          isCompleted INTEGER
        )
      ''');
      _dbLock.complete();
    } catch (e) {
      _dbLock.completeError(e);
    }
  }

  @override
  Future<void> createTask(Task task) async {
    await _dbLock.future;
    _db.execute('''
      INSERT INTO tasks (id, title, description, deadline, priority, isCompleted)
      VALUES (?, ?, ?, ?, ?, ?)
    ''', [
      task.id,
      task.title,
      task.description,
      task.deadline.toIso8601String(),
      task.priority,
      task.isCompleted ? 1 : 0
    ]);
  }

  @override
  Future<List<Task>> getAllTasks() async {
    await _dbLock.future;
    final result = _db.select('SELECT * FROM tasks');
    return result.map((row) {
      return Task.fromMap(row);
    }).toList();
  }

  @override
  Future<void> updateTask(Task task) async {
    await _dbLock.future;
    _db.execute('''
      UPDATE tasks
      SET title = ?, description = ?, deadline = ?, priority = ?, isCompleted = ?
      WHERE id = ?
    ''', [
      task.title,
      task.description,
      task.deadline.toIso8601String(),
      task.priority,
      task.isCompleted ? 1 : 0,
      task.id
    ]);
  }

  @override
  Future<void> deleteTask(String taskId) async {
    await _dbLock.future;
    _db.execute('DELETE FROM tasks WHERE id = ?', [taskId]);
  }

  // Datenbank schließen
  void close() {
    try {
      _db.dispose();
      print('Datenbank erfolgreich geschlossen.');
    } catch (e) {
      print('Fehler beim Schließen der Datenbank: $e');
    }
  }
}
