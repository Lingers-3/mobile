import 'dart:async';
import 'package:flutter/material.dart';
import 'package:pocketeer_mobile/data/services/auth_service.dart';
import 'package:pocketeer_mobile/ui/widgets/custom_dialog.dart';

class LogoutConfirmationDialog extends StatelessWidget {
  const LogoutConfirmationDialog({super.key});

  Future<void> _handleLogout(BuildContext context) async {
    final authService = AuthService();
    authService.logout(context);
  }

  @override
  Widget build(BuildContext context) {
    return CustomDialog(
      label: 'Logout',
      confirmationText: 'Are you sure you want to log out from account?',
      dialogFunction: () => _handleLogout(context),
    );
  }
}
