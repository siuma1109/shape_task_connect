import 'package:flutter/material.dart';
import '../../models/task_item.dart';
import '../../widgets/task/task_card.dart';
import '../../widgets/task/task_comments.dart';

class TaskDetailsScreen extends StatelessWidget {
  final TaskItem task;

  const TaskDetailsScreen({
    super.key,
    required this.task,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Task Details',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TaskCard(
            todo: task,
            isInDetails: true,
            isClickable: false,
          ),
          Expanded(
            child: TaskComments(taskId: task.id),
          ),
        ],
      ),
    );
  }
}
