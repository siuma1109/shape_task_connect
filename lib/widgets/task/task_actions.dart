import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:shape_task_connect/services/auth_service.dart';
import '../../models/task_item.dart';
import '../../repositories/task_repository.dart';

class TaskActions extends StatefulWidget {
  final TaskItem task;

  const TaskActions({
    super.key,
    required this.task,
  });

  @override
  State<TaskActions> createState() => _TaskActionsState();
}

class _TaskActionsState extends State<TaskActions> {
  final _taskRepository = GetIt.instance<TaskRepository>();
  final authService = GetIt.instance<AuthService>();
  bool _isJoined = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _checkJoinStatus();
  }

  Future<void> _checkJoinStatus() async {
    final userId = authService.currentUserDetails?.id;
    final isJoined =
        await _taskRepository.isUserJoined(widget.task.id!, userId!);
    if (mounted) {
      setState(() {
        _isJoined = isJoined;
      });
    }
  }

  Future<void> _toggleJoin() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final userId = GetIt.instance<AuthService>().currentUserDetails?.id;

      if (_isJoined) {
        await _taskRepository.leaveTask(widget.task.id!, userId!);
      } else {
        await _taskRepository.joinTask(widget.task.id!, userId!);
      }

      if (mounted) {
        setState(() {
          _isJoined = !_isJoined;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(_isJoined ? 'Joined task' : 'Left task'),
              backgroundColor: _isJoined ? Colors.green : Colors.orange,
            ),
          );
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to update task membership'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authService = GetIt.instance<AuthService>();
    final currentUserId = authService.currentUserDetails?.id;
    final isOwner = widget.task.createdBy == currentUserId;

    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        // Only show join/leave button if user is not the owner
        if (!isOwner)
          IconButton(
            icon: _isLoading
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Icon(_isJoined ? Icons.group_remove : Icons.group_add),
            onPressed: _toggleJoin,
            tooltip: _isJoined ? 'Leave task' : 'Join task',
          ),
        if (isOwner)
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              Navigator.pushNamed(
                context,
                '/edit-task',
                arguments: widget.task,
              );
            },
          ),
        if (isOwner)
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () async {
              final confirmed = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Delete Task'),
                  content:
                      const Text('Are you sure you want to delete this task?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text('Delete'),
                    ),
                  ],
                ),
              );

              if (confirmed == true) {
                final taskRepo = GetIt.instance<TaskRepository>();
                await taskRepo.deleteTask(widget.task.id!);
              }
            },
          ),
      ],
    );
  }
}
