import 'package:flutter/material.dart';
import '../../models/user.dart';
import '../../widgets/user/user_details.dart';
import '../../services/auth_service.dart';
import 'package:get_it/get_it.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

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
