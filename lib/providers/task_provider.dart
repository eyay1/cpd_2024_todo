import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/tasks.dart';
import 'dart:convert';

class TaskProvider with ChangeNotifier {
  List<Task> _tasks = [];

  List<Task> get tasks => _tasks;

  void addTask(Task task) {
    _tasks.add(task);
    saveTasks();
    notifyListeners();
  }

  void removeTask(int index) {
    _tasks.removeAt(index);
    saveTasks();
    notifyListeners();
  }

  void toggleTaskStatus(int index) {
    _tasks[index].isCompleted = !_tasks[index].isCompleted;
    saveTasks();
    notifyListeners();
  }

  void loadTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final tasksString = prefs.getString('tasks') ?? '[]';
    final tasksJson = json.decode(tasksString) as List;
    _tasks = tasksJson.map((taskJson) => Task.fromJson(taskJson)).toList();
    notifyListeners();
  }

  void saveTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final tasksString =
        json.encode(_tasks.map((task) => task.toJson()).toList());
    prefs.setString('tasks', tasksString);
  }

  void sortTasksByPriority() {
    _tasks.sort((a, b) => a.priority.compareTo(b.priority));
    notifyListeners();
  }

  void sortTasksByDeadline() {
    _tasks.sort((a, b) => a.deadline.compareTo(b.deadline));
    notifyListeners();
  }

  void sortTasksByStatus() {
    _tasks.sort((a, b) => a.isCompleted ? 1 : 0 - (b.isCompleted ? 1 : 0));
    notifyListeners();
  }
}
