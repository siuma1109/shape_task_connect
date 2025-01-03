import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:shape_task_connect/screens/main_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/register_screen.dart';
import '../services/auth_service.dart';

class AppRoutes {
  static final _authService = GetIt.instance<AuthService>();

  static Map<String, WidgetBuilder> get routes => {
        '/login': (context) => LoginScreen(authService: _authService),
        '/register': (context) => RegisterScreen(authService: _authService),
        '/home': (context) =>
            MainScreen(title: 'Task Connect', authService: _authService),
      };
}
