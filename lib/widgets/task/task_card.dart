import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../../models/task_item.dart';
import 'task_header.dart';
import 'task_content.dart';
import 'task_actions.dart';
import '../../screens/task/task_details_screen.dart';

class TaskCard extends StatelessWidget {
  final TaskItem todo;
  final bool isInDetails;
  final bool isClickable;

  const TaskCard({
    super.key,
    required this.todo,
    this.isInDetails = false,
    this.isClickable = true,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 0),
      elevation: 0,
      child: isClickable && !isInDetails
          ? Stack(
              children: [
                InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => TaskDetailsScreen(task: todo),
                      ),
                    );
                  },
                  child: _buildContent(),
                ),
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: IgnorePointer(
                    ignoring: false,
                    child: TaskActions(todo: todo, isInDetails: isInDetails),
                  ),
                ),
              ],
            )
          : _buildContent(),
    );
  }

  Widget _buildContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TaskHeader(todo: todo),
        TaskContent(todo: todo),
        if (!isClickable || !isInDetails)
          TaskActions(todo: todo, isInDetails: isInDetails),
      ],
    );
  }
}
