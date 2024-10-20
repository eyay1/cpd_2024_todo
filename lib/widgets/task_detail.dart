import 'package:flutter/material.dart';
import '../models/tasks.dart';

class TaskDetail extends StatelessWidget {
  final Task task;

  TaskDetail({required this.task});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(task.title)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Beschreibung: ${task.description}'),
            Text(
                'Deadline: ${task.deadline.year}-${task.deadline.month.toString().padLeft(2, '0')}-${task.deadline.day.toString().padLeft(2, '0')}'),
            Text(
                'Priorität: ${task.priority == 1 ? 'Hoch' : task.priority == 2 ? 'Mittel' : 'Niedrig'}'),
            Text('Status: ${task.isCompleted ? 'Erledigt' : 'Offen'}'),
          ],
        ),
      ),
    );
  }
}
