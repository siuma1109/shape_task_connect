import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import '../../models/task_item.dart';
import 'task_header.dart';
import 'task_content.dart';
import 'task_actions.dart';
import '../../screens/task/task_details_screen.dart';
import '../../repositories/comment_repository.dart';

class TaskCard extends StatefulWidget {
  final TaskItem task;
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
    _commentCountFuture =
        _commentRepository.countTaskComments(widget.task.id ?? 0);
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 0),
      elevation: 0,
      child: widget.isClickable && !widget.isInDetails
          ? InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => TaskDetailsScreen(
                      task: widget.task,
                      onRefresh: widget.onRefresh,
                    ),
                  ),
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
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            TaskActions(
                task: widget.task,
                onRefresh: widget.onRefresh,
                isInDetails: widget.isInDetails),
            if (!widget.isInDetails)
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
