import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import '../../services/auth_service.dart';
import '../../models/task.dart';
import '../../repositories/task_repository.dart';
import '../../widgets/task/task_list.dart';

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
  List<Task> _tasks = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final tasks = await _taskRepository.getAllTasks();
      if (mounted) {
        setState(() {
          _tasks = tasks;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading tasks: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> refreshTasks() async {
    await _loadTasks();
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
          )
        ],
      ),
      body: TaskList(
        tasks: _tasks,
        isLoading: _isLoading,
        onRefresh: refreshTasks,
      ),
    );
  }
}
