import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shape_task_connect/models/user.dart';

class Task {
  final String? id;
  final String title;
  final String description;
  final String createdBy;
  final Timestamp createdAt;
  final Timestamp dueDate;
  final bool completed;
  final User? user;

  Task({
    this.id,
    required this.title,
    required this.description,
    required this.createdBy,
    Timestamp? createdAt,
    required this.dueDate,
    this.completed = false,
    this.user,
  }) : createdAt = createdAt ?? Timestamp.now();

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'created_by': createdBy,
      'created_at': createdAt,
      'due_date': dueDate,
      'completed': completed ? true : false,
      'user': user?.toMap(),
    };
  }

  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      id: map['id'] as String,
      title: map['title'] as String,
      description: map['description'] as String,
      createdBy: map['created_by'] as String,
      createdAt: map['created_at'] as Timestamp,
      dueDate: map['due_date'] as Timestamp,
      completed: (map['completed'] as bool),
      user: map['user'] != null ? User.fromMap(map['user']) : null,
    );
  }
}
