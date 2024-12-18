import 'package:flutter/material.dart';
import '../../models/task_item.dart';
import '../../widgets/task/task_card.dart';
import '../../widgets/chat/chat_section.dart';

class TaskDetailsScreen extends StatelessWidget {
  final TaskItem task;

  const TaskDetailsScreen({super.key, required this.task});

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
        children: [
          TaskCard(todo: task, isInDetails: true),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Additional Details',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text('Task ID: ${task.id}'),
<<<<<<< HEAD
                Text('Created by: ${task.creatorName}'),
=======
                Text('Created by: User ${task.createdBy}'),
>>>>>>> 12f687185024beb015d0c6886d4a76643294884f
                Text('Created at: ${task.createdAt.toString()}'),
              ],
            ),
          ),
          const Expanded(
            child: ChatSection(),
          ),
        ],
      ),
    );
  }
}
