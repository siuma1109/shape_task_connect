import 'package:flutter/material.dart';
import 'screens/app_screen.dart';
import 'config/theme.dart';
import 'config/routes.dart';
import 'services/locator.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await setupLocator();
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
      home: AppScreen(),
      routes: AppRoutes.routes,
    );
  }
}
