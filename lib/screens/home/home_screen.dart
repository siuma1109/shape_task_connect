import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../../services/auth_service.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title, required this.authService});

  final String title;
  final AuthService authService;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
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
            icon: const Icon(CupertinoIcons.square_arrow_right),
            onPressed: _logout,
          ),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                CupertinoIcons.home,
                size: 100,
                color: CupertinoColors.systemGrey,
              ),
              const SizedBox(height: 16),
              Text(
                'Welcome to the Home Page!',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              Text(
                'You are now signed in',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: CupertinoColors.systemGrey,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
