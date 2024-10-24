import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'task_storage.dart';
import '../models/tasks.dart';

class TaskStorageSharedPreferences implements TaskStorage {
  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  static const String maxIdKey = 'max_task_id';

  Future<int> _getNextId() async {
    final SharedPreferences prefs = await _prefs;
    int currentMaxId = prefs.getInt(maxIdKey) ?? 0;
    int nextId = currentMaxId + 1;
    await prefs.setInt(maxIdKey, nextId);
    return nextId;
  }

  @override
  Future<void> createTask(Task task) async {
    final SharedPreferences prefs = await _prefs;

    if (task.id == null) {
      task.id = await _getNextId();
    }

    List<String> tasks = prefs.getStringList('tasks') ?? [];
    tasks.add(jsonEncode(task.toMap()));
    await prefs.setStringList('tasks', tasks);
  }

  @override
  Future<List<Task>> getAllTasks() async {
    final SharedPreferences prefs = await _prefs;
    List<String> tasks = prefs.getStringList('tasks') ?? [];
    return tasks.map((taskString) {
      return Task.fromMap(jsonDecode(taskString));
    }).toList();
  }

  @override
  Future<void> updateTask(Task task) async {
    final SharedPreferences prefs = await _prefs;
    List<String> tasks = prefs.getStringList('tasks') ?? [];
    int taskIndex = tasks.indexWhere((element) {
      Task tempTask = Task.fromMap(jsonDecode(element));
      return tempTask.id == task.id;
    });

    if (taskIndex != -1) {
      tasks[taskIndex] = jsonEncode(task.toMap());
      await prefs.setStringList('tasks', tasks);
    }
  }

  @override
  Future<void> deleteTask(int taskId) async {
    final SharedPreferences prefs = await _prefs;
    List<String> tasks = prefs.getStringList('tasks') ?? [];
    tasks.removeWhere((element) {
      Task tempTask = Task.fromMap(jsonDecode(element));
      return tempTask.id == taskId;
    });
    await prefs.setStringList('tasks', tasks);
  }
}
