import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../../services/auth_service.dart';
import '../../models/task_item.dart';
import '../../widgets/task/task_card.dart';
import '../../utils/demo_data.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.title, required this.authService});

  final String title;
  final AuthService authService;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Replace temporary mock data with demo data generator
  final List<TaskItem> _todoItems = DemoData.generateTasks(5);

  List<TaskItem> get _visibleTaskItems => _todoItems;

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
      body: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: _visibleTaskItems.length,
        itemBuilder: (context, index) {
          final todo = _visibleTaskItems[index];
          return TaskCard(todo: todo);
        },
      ),
    );
  }
}
