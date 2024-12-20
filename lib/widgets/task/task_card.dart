import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import '../../models/task.dart';
import 'task_header.dart';
import 'task_content.dart';
import 'task_actions.dart';
import '../../screens/task/task_comment_screen.dart';
import '../../repositories/comment_repository.dart';

class TaskCard extends StatefulWidget {
  final Task task;
  final bool isInDetails;
  final bool isClickable;
  final Future<void> Function()? onRefresh;

  const TaskCard({
    super.key,
    required this.task,
    this.isInDetails = false,
    this.isClickable = true,
    this.onRefresh,
  });

  @override
  State<TaskCard> createState() => _TaskCardState();
}

class _TaskCardState extends State<TaskCard> {
  final _commentRepository = GetIt.instance<CommentRepository>();
  late Future<int> _commentCountFuture;

  @override
  void initState() {
    super.initState();
    _loadCommentCount();
  }

  void _loadCommentCount() {
    _commentCountFuture = _commentRepository.countTaskComments(widget.task.id!);
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 0),
      elevation: 0,
      child: widget.isClickable && !widget.isInDetails
          ? InkWell(
              onTap: () async {
                final result = await TaskCommentScreen.show(
                  context,
                  widget.task,
                  onRefresh: widget.onRefresh,
                );
              },
              child: AbsorbPointer(
                absorbing: false,
                child: _buildContent(),
              ),
            )
          : _buildContent(),
    );
  }

  Widget _buildContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TaskHeader(task: widget.task),
        TaskContent(task: widget.task),
        Padding(
          padding: const EdgeInsets.fromLTRB(16.0, 12.0, 16.0, 8.0),
          child: Row(
            children: [
              Icon(
                Icons.event,
                size: 20,
                color: widget.task.dueDate.toDate().isBefore(DateTime.now())
                    ? Colors.red
                    : Colors.grey,
              ),
              const SizedBox(width: 8),
              Text(
                '${widget.task.dueDate.toDate().year}-${widget.task.dueDate.toDate().month}-${widget.task.dueDate.toDate().day}',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color:
                          widget.task.dueDate.toDate().isBefore(DateTime.now())
                              ? Colors.red
                              : null,
                    ),
              ),
              const SizedBox(width: 24),
              Icon(
                widget.task.completed
                    ? Icons.check_circle
                    : Icons.check_circle_outline,
                size: 20,
                color: widget.task.completed ? Colors.green : Colors.grey,
              ),
              const SizedBox(width: 8),
              Text(
                widget.task.completed ? 'Completed' : 'Pending',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: widget.task.completed ? Colors.green : null,
                    ),
              ),
            ],
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            TaskActions(
                task: widget.task,
                onRefresh: widget.onRefresh,
                isInDetails: widget.isInDetails),
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: FutureBuilder<int>(
                future: _commentCountFuture,
                builder: (context, snapshot) {
                  final count = snapshot.data ?? 0;
                  return Row(
                    children: [
                      const Icon(Icons.comment_outlined, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        count.toString(),
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ],
    );
  }
}
