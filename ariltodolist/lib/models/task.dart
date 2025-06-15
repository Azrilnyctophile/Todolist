class Task {
  final int? id;
  final String title;
  final String priority;
  final String dueDate;
  final bool isDone;

  Task({
    this.id,
    required this.title,
    required this.priority,
    required this.dueDate,
    this.isDone = false,
  });

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'],
      title: json['title'],
      priority: json['priority'],
      dueDate: json['due_date'],
      isDone: json['is_done'].toString() == '1' || json['is_done'] == true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "title": title,
      "priority": priority,
      "due_date": dueDate,
      "is_done": isDone ? 1 : 0,
    };
  }
}
