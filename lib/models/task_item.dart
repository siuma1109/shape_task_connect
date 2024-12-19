import 'package:shape_task_connect/models/user.dart';

class TaskItem {
  final int? id;
  final String title;
  final String description;
  final int createdBy;
  final DateTime? createdAt;
  final DateTime dueDate;
  final bool completed;
  final User? user;

  TaskItem({
    this.id,
    required this.title,
    required this.description,
    required this.createdBy,
    this.createdAt,
    required this.dueDate,
    this.completed = false,
    this.user,
  });

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'created_by': createdBy,
      'due_date': dueDate.toString(),
      'completed': completed ? 1 : 0,
    };
  }

  factory TaskItem.fromMap(Map<String, dynamic> map) {
    return TaskItem(
      id: map['id'] as int,
      title: map['title'] as String,
      description: map['description'] as String,
      createdBy: map['created_by'] as int,
      createdAt: DateTime.parse(map['created_at'] as String),
      dueDate: DateTime.parse(map['due_date'] as String),
      completed: (map['completed'] as int) == 1,
      user: map['user'] != null ? User.fromMap(map['user']) : null,
    );
  }
}
