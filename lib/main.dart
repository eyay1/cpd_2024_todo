import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/task_provider.dart';
//import 'storage/task_storage_shared_preferences.dart';
import 'storage/task_storage_sqlite.dart';
//import 'storage/task_storage_postgres.dart';
import 'widgets/task_form.dart';
import 'widgets/task_detail.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  //TaskStoragePostgres storage = TaskStoragePostgres();
  TaskStorageSQLite storage = TaskStorageSQLite();
  //TaskStorageSharedPreferences storage = TaskStorageSharedPreferences();

  runApp(
    ChangeNotifierProvider(
      create: (context) => TaskProvider(storage)..loadTasks(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
            seedColor: const Color.fromRGBO(103, 58, 183, 1)),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'To-Do-Liste'),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    final taskProvider = Provider.of<TaskProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'priority') {
                taskProvider.sortTasksByPriority();
              } else if (value == 'deadline') {
                taskProvider.sortTasksByDeadline();
              } else if (value == 'status') {
                taskProvider.sortTasksByStatus();
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                  value: 'priority', child: Text('Nach Priorität')),
              const PopupMenuItem(
                  value: 'deadline', child: Text('Nach Deadline')),
              const PopupMenuItem(value: 'status', child: Text('Nach Status')),
            ],
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: taskProvider.tasks.length,
                shrinkWrap: true,
                itemBuilder: (context, index) {
                  final task = taskProvider.tasks[index];
                  print("Tasks: ID: ${task.id} , Titel: ${task.title}");
                  return Dismissible(
                    key: Key(task.title),
                    direction: DismissDirection.endToStart,
                    background: Container(
                      color: Colors.red,
                      alignment: AlignmentDirectional.centerEnd,
                      child: const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20.0),
                        child: Icon(
                          Icons.delete,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    onDismissed: (direction) {
                      taskProvider.removeTask(index);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Aufgabe "${task.title}" gelöscht'),
                          action: SnackBarAction(
                            label: 'Rückgängig',
                            onPressed: () {
                              taskProvider.addTask(task);
                            },
                          ),
                        ),
                      );
                    },
                    child: ListTile(
                      title: Row(
                        children: [
                          Expanded(
                            child: Text(
                              task.title,
                              style: TextStyle(
                                decoration: task.isCompleted
                                    ? TextDecoration.lineThrough
                                    : TextDecoration.none,
                              ),
                            ),
                          ),
                          IconButton(
                            icon: Icon(
                              Icons.check_circle,
                              color:
                                  task.isCompleted ? Colors.green : Colors.grey,
                            ),
                            onPressed: () {
                              taskProvider.toggleTaskStatus(index);
                            },
                          ),
                        ],
                      ),
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => TaskDetail(task: task),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => TaskForm(),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
