import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../../models/task_item.dart';

class TaskActions extends StatelessWidget {
  final TaskItem todo;
  final bool isInDetails;

  const TaskActions({
    super.key,
    required this.todo,
    this.isInDetails = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Material(
        color: Colors.transparent,
        child: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.group_add),
              onPressed: () {
                // TODO: Implement join task
              },
              tooltip: 'Join Task',
            ),
            if (!isInDetails)
              IconButton(
                icon: const Icon(CupertinoIcons.chat_bubble_2),
                onPressed: () {
                  // TODO: Implement comments
                },
                tooltip: 'Comments',
              ),
          ],
        ),
      ),
    );
  }
}
