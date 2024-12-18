import 'package:flutter/material.dart';
import '../../services/auth_service.dart';

class ProfileScreen extends StatelessWidget {
  final AuthService authService;

  const ProfileScreen({super.key, required this.authService});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'My Profile',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: const Center(
        child: Text('Profile Screen'),
      ),
    );
  }
}
