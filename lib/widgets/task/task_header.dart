import 'package:flutter/material.dart';
import '../../models/task_item.dart';
import '../../../utils/date_formatter.dart';

class TaskHeader extends StatelessWidget {
  final TaskItem task;

  const TaskHeader({super.key, required this.task});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Row(
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: Theme.of(context).primaryColor,
            child: Text(
              task.createdBy.toString(),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'User ${task.createdBy}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  DateFormatter.getTimeAgo(task.createdAt ?? DateTime.now()),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
