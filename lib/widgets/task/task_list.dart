import 'package:flutter/material.dart';
import '../../models/task_item.dart';
import 'task_card.dart';

class TaskList extends StatelessWidget {
  final List<TaskItem> tasks;
  final bool isLoading;
  final Future<void> Function() onRefresh;
  final EdgeInsetsGeometry? padding;

  const TaskList({
    super.key,
    required this.tasks,
    required this.onRefresh,
    this.isLoading = false,
    this.padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (tasks.isEmpty) {
      return RefreshIndicator(
        onRefresh: onRefresh,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: const [
            Center(
              child: Padding(
                padding: EdgeInsets.only(top: 100),
                child: Text('No tasks found'),
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: padding,
        itemCount: tasks.length,
        itemBuilder: (context, index) {
          return TaskCard(
            task: tasks[index],
            onRefresh: onRefresh,
          );
        },
      ),
    );
  }
}
