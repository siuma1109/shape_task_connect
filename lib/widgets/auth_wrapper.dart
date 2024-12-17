import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:shape_task_connect/services/auth_service.dart';
import '../screens/auth/login_screen.dart';
import '../widgets/main_wrapper.dart';

class AuthWrapper extends StatelessWidget {
  final _authService = GetIt.I<AuthService>();

  AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _authService.checkLoginStatus(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final bool isLoggedIn = snapshot.data ?? false;
        return isLoggedIn
            ? MainWrapper(title: 'Task Connect', authService: _authService)
            : LoginScreen(authService: _authService);
      },
    );
  }
}
