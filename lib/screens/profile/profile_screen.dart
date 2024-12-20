import 'package:flutter/material.dart';
import 'package:shape_task_connect/models/user.dart';
import '../../widgets/user/user_details.dart';
import '../../services/auth_service.dart';
import 'package:get_it/get_it.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    final authService = GetIt.instance<AuthService>();
    final User currentUser = authService.currentUserDetails!;

    return UserDetails(
      user: currentUser,
      showLogout: true,
    );
  }
}
