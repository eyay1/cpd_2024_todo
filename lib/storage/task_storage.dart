import '../models/tasks.dart';

abstract class TaskStorage {
  Future<void> createTask(Task task);
  Future<List<Task>> getAllTasks();
  Future<void> updateTask(Task task);
  Future<void> deleteTask(int taskId);
}
