import 'package:sqlite3/sqlite3.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'task_storage.dart';
import '../models/tasks.dart';
import 'dart:async';

class TaskStorageSQLite implements TaskStorage {
  late Database _db;
  final _dbLock = Completer<void>();

  // Konstruktor, der die Datenbank asynchron initialisiert
  TaskStorageSQLite() {
    _initializeDatabase();
  }

  // Asynchrone Methode zur Initialisierung der Datenbank
  Future<void> _initializeDatabase() async {
    try {
      // Pfad des Datenbankordners ermitteln (für Flutter wichtig)
      final directory = await getApplicationDocumentsDirectory();
      final dbPath = path.join(directory.path, 'todo_app.db');

      // SQLite-Datenbank öffnen oder erstellen
      _db = sqlite3.open(dbPath);

      // Tabelle erstellen, falls sie noch nicht existiert
      _db.execute('''
        CREATE TABLE IF NOT EXISTS tasks (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          title TEXT,
          description TEXT,
          deadline TEXT,
          priority INTEGER,
          isCompleted INTEGER
        )
      ''');
      print('Datenbank und Tabelle erfolgreich initialisiert.');
      _dbLock
          .complete(); // Signalisiert, dass die Initialisierung abgeschlossen ist
    } catch (e) {
      print('Fehler bei der Initialisierung der Datenbank: $e');
      if (!_dbLock.isCompleted)
        _dbLock.completeError(e); // Setzt den Fehlerfall im Completer
    }
  }

  // Generische Methode zur Ausführung von DB-Operationen
  Future<T> _executeDbOperation<T>(Future<T> Function() operation) async {
    await _dbLock.future; // Wartet, bis die Datenbank initialisiert ist
    return operation();
  }

  // Aufgabe erstellen
  @override
  Future<void> createTask(Task task) async {
    await _executeDbOperation(() async {
      try {
        // Führe das INSERT ohne ID durch, um AUTOINCREMENT zu verwenden
        _db.execute('''
          INSERT INTO tasks (title, description, deadline, priority, isCompleted)
          VALUES (?, ?, ?, ?, ?)
        ''', [
          task.title,
          task.description,
          task.deadline.toIso8601String(),
          task.priority,
          task.isCompleted ? 1 : 0
        ]);
        print('Aufgabe erfolgreich hinzugefügt.');
      } catch (e) {
        print('Fehler beim Hinzufügen der Aufgabe: $e');
      }
    });
  }

  // Alle Aufgaben abrufen
  @override
  Future<List<Task>> getAllTasks() async {
    return await _executeDbOperation(() async {
      try {
        final ResultSet result = _db.select('SELECT * FROM tasks');
        return result.map((row) {
          return Task(
            id: row['id'] as int,
            title: row['title'] as String,
            description: row['description'] as String,
            deadline: DateTime.parse(row['deadline'] as String),
            priority: row['priority'] as int,
            isCompleted: (row['isCompleted'] as int) == 1,
          );
        }).toList();
      } catch (e) {
        print('Fehler beim Abrufen der Aufgaben: $e');
        return [];
      }
    });
  }

  // Aufgabe aktualisieren
  @override
  Future<void> updateTask(Task task) async {
    await _executeDbOperation(() async {
      try {
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
        print('Aufgabe erfolgreich aktualisiert.');
      } catch (e) {
        print('Fehler beim Aktualisieren der Aufgabe: $e');
      }
    });
  }

  // Aufgabe löschen
  @override
  Future<void> deleteTask(int taskId) async {
    await _executeDbOperation(() async {
      try {
        _db.execute('DELETE FROM tasks WHERE id = ?', [taskId]);
        print('Aufgabe erfolgreich gelöscht.');
      } catch (e) {
        print('Fehler beim Löschen der Aufgabe: $e');
      }
    });
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
