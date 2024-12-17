import 'package:flutter/material.dart';
import 'widgets/auth_wrapper.dart';
import 'config/theme.dart';
import 'config/routes.dart';
import 'services/locator.dart';

void main() {
  setupLocator();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Task Connect',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      home: AuthWrapper(),
      routes: AppRoutes.routes,
    );
  }
}
