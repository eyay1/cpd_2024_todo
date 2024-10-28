import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';
import 'task_storage.dart';
import '../models/tasks.dart';

class TaskStorageSecureStorage implements TaskStorage {
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  @override
  Future<void> createTask(Task task) async {
    List<Task> tasks = await getAllTasks();
    tasks.add(task);
    await _saveTasks(tasks);
  }

  @override
  Future<List<Task>> getAllTasks() async {
    String? tasksJson = await _secureStorage.read(key: 'tasks');
    if (tasksJson != null) {
      List<dynamic> tasksList = jsonDecode(tasksJson);
      return tasksList.map((taskMap) => Task.fromMap(taskMap)).toList();
    }
    return [];
  }

  @override
  Future<void> updateTask(Task task) async {
    List<Task> tasks = await getAllTasks();
    int index = tasks.indexWhere((t) => t.id == task.id);
    if (index != -1) {
      tasks[index] = task;
      await _saveTasks(tasks);
    }
  }

  @override
  Future<void> deleteTask(String taskId) async {
    List<Task> tasks = await getAllTasks();
    tasks.removeWhere((task) => task.id == taskId);
    await _saveTasks(tasks);
  }

  Future<void> _saveTasks(List<Task> tasks) async {
    String tasksJson = jsonEncode(tasks.map((task) => task.toMap()).toList());
    await _secureStorage.write(key: 'tasks', value: tasksJson);
  }
}
