import 'package:flutter/material.dart';
import '../models/tasks.dart';

class TaskDetail extends StatelessWidget {
  final Task task;
  final Color seedColor = const Color.fromARGB(255, 191, 162, 241);

  TaskDetail({required this.task});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(task.title),
        backgroundColor: seedColor, // Verwenden Sie die angegebene Farbe hier
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          color: Colors.white, // Setzen Sie die Kartenfarbe auf Weiß
          elevation: 4.0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ListTile(
                  title: Text(
                    'Beschreibung',
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.black),
                  ),
                  subtitle: Text(task.description,
                      style: TextStyle(color: Colors.black)),
                ),
                Divider(),
                ListTile(
                  title: Text(
                    'Deadline',
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.black),
                  ),
                  subtitle: Text(
                    '${task.deadline.year}-${task.deadline.month.toString().padLeft(2, '0')}-${task.deadline.day.toString().padLeft(2, '0')}',
                    style: TextStyle(color: Colors.black),
                  ),
                ),
                Divider(),
                ListTile(
                  title: Text(
                    'Priorität',
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.black),
                  ),
                  subtitle: Text(
                    task.priority == 1
                        ? 'Hoch'
                        : task.priority == 2
                            ? 'Mittel'
                            : 'Niedrig',
                    style: TextStyle(color: Colors.black),
                  ),
                ),
                Divider(),
                ListTile(
                  title: Text(
                    'Status',
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.black),
                  ),
                  subtitle: Text(
                    task.isCompleted ? 'Erledigt' : 'Offen',
                    style: TextStyle(color: Colors.black),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
