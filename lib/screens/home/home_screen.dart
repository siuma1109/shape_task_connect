import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../../services/auth_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.title, required this.authService});

  final String title;
  final AuthService authService;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Future<void> _logout() async {
    await widget.authService.logout();
    if (mounted) {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    final userDetails = widget.authService.currentUserDetails;

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
                CupertinoIcons.person_circle_fill,
                size: 100,
                color: CupertinoColors.systemGrey,
              ),
              const SizedBox(height: 16),
              Text(
                'Welcome, ${userDetails?.username ?? "User"}!',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              Text(
                userDetails?.email ?? '',
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
