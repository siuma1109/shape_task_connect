import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import '../../models/comment.dart';
import '../../repositories/comment_repository.dart';

class TaskComments extends StatefulWidget {
  final String taskId;

  const TaskComments({
    super.key,
    required this.taskId,
  });

  @override
  State<TaskComments> createState() => _TaskCommentsState();
}

class _TaskCommentsState extends State<TaskComments> {
  final _commentRepository = GetIt.instance<CommentRepository>();
  final _commentController = TextEditingController();
  late Future<List<Comment>> _commentsFuture;

  @override
  void initState() {
    super.initState();
    _loadComments();
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  void _loadComments() {
    setState(() {
      _commentsFuture = _commentRepository.getCommentsByTask(widget.taskId);
    });
  }

  Future<void> _refreshComments() async {
    _loadComments();
  }

  Future<void> _addComment() async {
    final content = _commentController.text.trim();
    if (content.isEmpty) return;

    try {
      setState(() {
        _commentController.clear();
        FocusScope.of(context).unfocus(); // Hide keyboard after sending
      });

      final comment = Comment(
        taskId: widget.taskId,
        userId: 1, // Using test user for now
        content: content,
        createdAt: DateTime.now(),
      );

      await _commentRepository.createComment(comment);
      _refreshComments();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to add comment. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Comments',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: _refreshComments,
              ),
            ],
          ),
        ),
        Expanded(
          child: RefreshIndicator(
            onRefresh: _refreshComments,
            child: FutureBuilder<List<Comment>>(
              future: _commentsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                final comments = snapshot.data ?? [];

                if (comments.isEmpty) {
                  return ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: const [
                      Center(
                        child: Padding(
                          padding: EdgeInsets.only(top: 100),
                          child: Text('No comments yet'),
                        ),
                      ),
                    ],
                  );
                }

                return ListView.builder(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: comments.length,
                  itemBuilder: (context, index) {
                    final comment = comments[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'User ${comment.userId}',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.copyWith(fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  comment.createdAt.toString(),
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(comment.content),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 4,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _commentController,
                  decoration: const InputDecoration(
                    hintText: 'Add a comment...',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                  maxLines: null,
                  textInputAction: TextInputAction.send,
                  onSubmitted: (_) => _addComment(),
                ),
              ),
              const SizedBox(width: 16),
              IconButton(
                icon: const Icon(Icons.send),
                onPressed: _addComment,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
