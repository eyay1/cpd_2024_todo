class Task {
  String title;
  String description;
  DateTime deadline;
  int priority;
  bool isCompleted;

  Task({
    required this.title,
    required this.description,
    required this.deadline,
    required this.priority,
    this.isCompleted = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'deadline': deadline.toIso8601String(),
      'priority': priority,
      'isDone': isCompleted
    };
  }

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      title: json['title'],
      description: json['description'],
      deadline: DateTime.parse(json['deadline']),
      priority: json['priority'],
      isCompleted: json['isDone'],
    );
  }
}
