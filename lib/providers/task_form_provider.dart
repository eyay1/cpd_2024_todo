import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/tasks.dart';
import '../providers/task_provider.dart';

class TaskFormProvider with ChangeNotifier {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  int _selectedPriority = 1;

  GlobalKey<FormState> get formKey => _formKey;
  TextEditingController get titleController => _titleController;
  TextEditingController get descriptionController => _descriptionController;
  DateTime get selectedDate => _selectedDate;
  int get selectedPriority => _selectedPriority;

  void setSelectedDate(DateTime date) {
    _selectedDate = date;
    notifyListeners();
  }

  void setSelectedPriority(int priority) {
    _selectedPriority = priority;
    notifyListeners();
  }

  void submitForm(BuildContext context) {
    if (_formKey.currentState!.validate()) {
      final newTask = Task(
        title: _titleController.text,
        description: _descriptionController.text,
        deadline: _selectedDate,
        priority: _selectedPriority,
      );
      Provider.of<TaskProvider>(context, listen: false).addTask(newTask);
      Navigator.of(context).pop();
    }
  }
}
