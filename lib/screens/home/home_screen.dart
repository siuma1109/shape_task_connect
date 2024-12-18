import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:get_it/get_it.dart';
import '../../services/auth_service.dart';
import '../../models/task_item.dart';
import '../../widgets/task/task_card.dart';
import '../../services/database_service.dart';
import '../../repositories/task_repository.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    super.key,
    required this.title,
    required this.authService,
  });

  final String title;
  final AuthService authService;

  @override
  State<HomeScreen> createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  final _taskRepository = GetIt.instance<TaskRepository>();
  late Future<List<TaskItem>> _tasksFuture;

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  void _loadTasks() {
    setState(() {
      _tasksFuture = _taskRepository.getAllTasks();
    });
  }

  Future<void> refreshTasks() async {
    _loadTasks();
  }

  Future<void> _logout() async {
    await widget.authService.logout();
    if (mounted) {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: refreshTasks,
          ),
          IconButton(
            icon: const Icon(CupertinoIcons.chat_bubble_2),
            onPressed: () {
              // TODO: Implement chat feature
            },
          ),
          IconButton(
            icon: const Icon(CupertinoIcons.square_arrow_right),
            onPressed: _logout,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: refreshTasks,
        child: FutureBuilder<List<TaskItem>>(
          future: _tasksFuture,
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
                physics: const AlwaysScrollableScrollPhysics(),
                children: const [
                  Center(
                    child: Padding(
                      padding: EdgeInsets.only(top: 100),
                      child: Text('No tasks found'),
                    ),
                  ),
                ],
              );
            }

            return ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: tasks.length,
              itemBuilder: (context, index) {
                return TaskCard(todo: tasks[index]);
              },
            );
          },
        ),
      ),
    );
  }
}
