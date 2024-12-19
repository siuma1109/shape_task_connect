import 'package:flutter/material.dart';
import '../../models/user.dart';
import '../../models/task_item.dart';
import '../../repositories/task_repository.dart';
import '../../widgets/task/task_card.dart';
import 'package:get_it/get_it.dart';

class UserDetails extends StatefulWidget {
  final User user;

  const UserDetails({
    super.key,
    required this.user,
  });

  @override
  State<UserDetails> createState() => _UserDetailsState();
}

class _UserDetailsState extends State<UserDetails> {
  final _taskRepository = GetIt.instance<TaskRepository>();
  late Future<List<TaskItem>> _userTasksFuture;

  @override
  void initState() {
    super.initState();
    _loadUserTasks();
  }

  void _loadUserTasks() {
    setState(() {
      _userTasksFuture = _taskRepository.getTasksByUser(widget.user.id!);
    });
  }

  Future<void> _refreshTasks() async {
    _loadUserTasks();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.user.username,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshTasks,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshTasks,
        child: Column(
          children: [
            // User Info Card
            Card(
              margin: const EdgeInsets.all(16),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 30,
                          child: Text(
                            widget.user.username[0].toUpperCase(),
                            style: const TextStyle(fontSize: 24),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.user.username,
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                widget.user.email,
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // User's Tasks
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Text(
                    'Tasks',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ],
              ),
            ),

            // Tasks List
            Expanded(
              child: FutureBuilder<List<TaskItem>>(
                future: _userTasksFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }

                  final tasks = snapshot.data ?? [];

                  if (tasks.isEmpty) {
                    return ListView(
                      // Wrap with ListView for RefreshIndicator to work
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: const [
                        Center(
                          child: Padding(
                            padding: EdgeInsets.only(top: 100),
                            child: Text('No tasks found for this user'),
                          ),
                        ),
                      ],
                    );
                  }

                  return ListView.builder(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(16),
                    itemCount: tasks.length,
                    itemBuilder: (context, index) {
                      return TaskCard(task: tasks[index]);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
