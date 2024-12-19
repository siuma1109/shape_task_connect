import 'package:flutter/material.dart';
import '../../models/task_item.dart';
import '../../widgets/task/task_card.dart';
import '../../widgets/task/task_comments.dart';

class TaskDetailsScreen extends StatefulWidget {
  final TaskItem task;
  final Future<void> Function()? onRefresh;

  const TaskDetailsScreen({
    super.key,
    required this.task,
    this.onRefresh,
  });

  @override
  State<TaskDetailsScreen> createState() => _TaskDetailsScreenState();
}

class _TaskDetailsScreenState extends State<TaskDetailsScreen> {
  late TaskItem _task;

  @override
  void initState() {
    super.initState();
    _task = widget.task;
  }

  Future<void> onTaskUpdated(TaskItem updatedTask) async {
    setState(() {
      _task = updatedTask;
    });
    if (widget.onRefresh != null) {
      await widget.onRefresh!();
    }
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop && widget.onRefresh != null) {
          await widget.onRefresh!();
        }
      },
      child: Scaffold(
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
              task: _task,
              isInDetails: true,
              isClickable: false,
              onRefresh: widget.onRefresh,
            ),
            Expanded(
              child: TaskComments(taskId: _task.id ?? 0),
            ),
          ],
        ),
      ),
    );
  }
}
