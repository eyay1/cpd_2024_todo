import 'package:flutter/material.dart';
import '../storage/task_storage.dart';
import '../models/tasks.dart';

class TaskProvider with ChangeNotifier {
  final TaskStorage storage;
  List<Task> _tasks = [];

  TaskProvider(this.storage);

  List<Task> get tasks => _tasks;

  Future<void> loadTasks() async {
    _tasks = await storage.getAllTasks();
    notifyListeners();
  }

  Future<void> addTask(Task task) async {
    await storage.createTask(task);
    tasks.add(task);
    notifyListeners();
  }

  Future<void> removeTask(int index) async {
    final taskId = tasks[index].id;
    if (taskId != null) {
      await storage.deleteTask(taskId);
    }
    tasks.removeAt(index);
    notifyListeners();
  }

  Future<void> updateTask(Task updatedTask) async {
    await storage.updateTask(updatedTask);
    final index = tasks.indexWhere((task) => task.id == updatedTask.id);
    if (index != -1) {
      tasks[index] = updatedTask;
      notifyListeners();
    }
  }

  void toggleTaskStatus(int index) {
    final task = tasks[index];
    task.isCompleted = !task.isCompleted;
    updateTask(task);
  }

  void sortTasksByPriority() {
    tasks.sort((a, b) => b.priority.compareTo(a.priority));
    notifyListeners();
  }

  void sortTasksByDeadline() {
    tasks.sort((a, b) => a.deadline.compareTo(b.deadline));
    notifyListeners();
  }

  void sortTasksByStatus() {
    tasks.sort((a, b) => a.isCompleted ? 1 : -1);
    notifyListeners();
  }
}
