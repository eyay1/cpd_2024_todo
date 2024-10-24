import 'package:postgres/postgres.dart';
import 'task_storage.dart';
import '../models/tasks.dart';

class TaskStoragePostgres implements TaskStorage {
  late PostgreSQLConnection _connection;

  TaskStoragePostgres() {
    _initializeDatabase();
  }

  Future<void> _initializeDatabase() async {
    print('Verbindungsaufbau zu PostgreSQL...');

    _connection = PostgreSQLConnection(
      'localhost',
      5432,
      'postgres',
      username: 'postgres',
      password: 'admin',
    );

    try {
      await _connection.open();
      print('Erfolgreich mit der PostgreSQL-Datenbank verbunden.');
      print('Verbundene Datenbank: ${_connection.databaseName}');
      print('Host: ${_connection.host}, Port: ${_connection.port}');
    } catch (e) {
      print('Fehler beim Verbinden: $e');
    }

    await _createDatabaseIfNotExists();

    await _connection.close();
    _connection = PostgreSQLConnection(
      'localhost',
      5432,
      'todo_app',
      username: 'postgres',
      password: 'admin',
    );

    try {
      await _connection.open();
      print('Erfolgreich mit der Datenbank "todo_app" verbunden.');
    } catch (e) {
      print('Fehler beim Verbinden mit der todo_app-Datenbank: $e');
    }

    await _createTableIfNotExists();
  }

  Future<void> _createDatabaseIfNotExists() async {
    var result = await _connection
        .query("SELECT 1 FROM pg_database WHERE datname = 'todo_app'");
    if (result.isEmpty) {
      await _connection.query('CREATE DATABASE todo_app');
      print('Datenbank "todo_app" erstellt.');
    } else {
      print('Datenbank "todo_app" existiert bereits.');
    }
  }

  Future<void> _createTableIfNotExists() async {
    await _connection.query('''
      CREATE TABLE IF NOT EXISTS tasks (
        id SERIAL PRIMARY KEY,
        title TEXT NOT NULL,
        description TEXT,
        deadline DATE,
        priority INT,
        isCompleted BOOLEAN
      )
    ''');
    print('Tabelle "tasks" wurde erstellt oder existiert bereits.');
  }

  @override
  Future<void> createTask(Task task) async {
    await _connection.query(
      'INSERT INTO tasks (title, description, deadline, priority, isCompleted) VALUES (@title, @description, @deadline, @priority, @isCompleted)',
      substitutionValues: {
        'title': task.title,
        'description': task.description,
        'deadline': task.deadline.toIso8601String(),
        'priority': task.priority,
        'isCompleted': task.isCompleted ? 1 : 0,
      },
    );
    print('Aufgabe hinzugefügt: ${task.title}');
  }

  @override
  Future<List<Task>> getAllTasks() async {
    var results = await _connection.query('SELECT * FROM tasks');
    print('Anzahl der abgerufenen Aufgaben: ${results.length}');
    return results.map((row) {
      return Task(
        id: row[0] as int,
        title: row[1] as String,
        description: row[2] as String,
        deadline: DateTime.parse(row[3] as String),
        priority: row[4] as int,
        isCompleted: row[5] == 1,
      );
    }).toList();
  }

  @override
  Future<void> updateTask(Task task) async {
    await _connection.query(
      'UPDATE tasks SET title = @title, description = @description, deadline = @deadline, priority = @priority, isCompleted = @isCompleted WHERE id = @id',
      substitutionValues: {
        'id': task.id,
        'title': task.title,
        'description': task.description,
        'deadline': task.deadline.toIso8601String(),
        'priority': task.priority,
        'isCompleted': task.isCompleted ? 1 : 0,
      },
    );
    print('Aufgabe aktualisiert: ${task.title}');
  }

  @override
  Future<void> deleteTask(int taskId) async {
    await _connection.query(
      'DELETE FROM tasks WHERE id = @id',
      substitutionValues: {
        'id': taskId,
      },
    );
    print('Aufgabe gelöscht: $taskId');
  }
}
