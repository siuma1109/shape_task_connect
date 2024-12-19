import 'package:flutter/material.dart';
import '../../models/task_item.dart';
import '../../widgets/task/task_comments.dart';

class TaskCommentScreen extends StatefulWidget {
  final TaskItem task;
  final Future<void> Function()? onRefresh;

  const TaskCommentScreen({
    super.key,
    required this.task,
    this.onRefresh,
  });

  static Future<bool?> show(BuildContext context, TaskItem task,
      {Future<void> Function()? onRefresh}) {
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.75,
      ),
      builder: (context) => TaskCommentScreen(task: task, onRefresh: onRefresh),
    );
  }

  @override
  State<TaskCommentScreen> createState() => _TaskCommentScreenState();
}

class _TaskCommentScreenState extends State<TaskCommentScreen> {
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
    return Container(
      height: double.infinity,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          _buildHandle(),
          _buildHeader(),
          Expanded(
            child: TaskComments(taskId: _task.id ?? 0),
          ),
        ],
      ),
    );
  }

  Widget _buildHandle() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Container(
        width: 40,
        height: 4,
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Colors.grey[200]!,
            width: 1,
          ),
        ),
      ),
      child: const Row(
        children: [
          Text(
            'Comments',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}
