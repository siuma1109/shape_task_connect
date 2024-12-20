import 'package:flutter/material.dart';
import 'screens/app_screen.dart';
import 'config/theme.dart';
import 'config/routes.dart';
import 'services/locator.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'config/firebase_config.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables
  await dotenv.load(fileName: ".env");

  // Initialize Firebase with configuration from .env
  await Firebase.initializeApp();

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
