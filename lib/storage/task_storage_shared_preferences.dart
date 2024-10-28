import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'task_storage.dart';
import '../models/tasks.dart';

class TaskStorageSharedPreferences implements TaskStorage {
  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  @override
  Future<void> createTask(Task task) async {
    final SharedPreferences prefs = await _prefs;
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
  Future<void> deleteTask(String taskId) async {
    final SharedPreferences prefs = await _prefs;
    List<String> tasks = prefs.getStringList('tasks') ?? [];
    tasks.removeWhere((element) {
      Task tempTask = Task.fromMap(jsonDecode(element));
      return tempTask.id == taskId;
    });
    await prefs.setStringList('tasks', tasks);
  }
}
