import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
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
  bool _isJoined = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _checkJoinStatus();
  }

  Future<void> _checkJoinStatus() async {
    // TODO: Get actual user ID
    const userId = 1;
    final isJoined = await _taskRepository.isUserJoined(widget.task.id, userId);
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
      // TODO: Get actual user ID
      const userId = 1;

      if (_isJoined) {
        await _taskRepository.leaveTask(widget.task.id, userId);
      } else {
        await _taskRepository.joinTask(widget.task.id, userId);
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
    return IconButton(
      icon: _isLoading
          ? const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : Icon(_isJoined ? Icons.group_remove : Icons.group_add),
      onPressed: _toggleJoin,
      tooltip: _isJoined ? 'Leave task' : 'Join task',
    );
  }
}
