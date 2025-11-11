import 'package:flutter/material.dart';
import 'package:pocketeer_mobile/data/services/auth_service.dart';

class ChangePasswordController {
  final newPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  bool get hasMinLength => newPasswordController.text.length >= 8;
  bool get hasLower => RegExp(r'[a-z]').hasMatch(newPasswordController.text);
  bool get hasUpper => RegExp(r'[A-Z]').hasMatch(newPasswordController.text);
  bool get hasNumber => RegExp(r'\d').hasMatch(newPasswordController.text);
  bool get hasSpecial => RegExp(
    r'[!@#\$%^&*(),.?":{}|<>_`";]',
  ).hasMatch(newPasswordController.text);

  int get complexity {
    int c = 0;
    if (hasLower) c++;
    if (hasUpper) c++;
    if (hasNumber) c++;
    if (hasSpecial) c++;
    return c;
  }

  Future<bool> changePassword(BuildContext context) async {
    final newPassword = newPasswordController.text.trim();
    return await AuthService().changePassword(newPassword);
  }

  void dispose() {
    newPasswordController.dispose();
    confirmPasswordController.dispose();
  }
}
