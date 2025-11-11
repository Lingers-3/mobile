import 'package:flutter/material.dart';
import 'package:pocketeer_mobile/ui/views/auth/auth_gate.dart';
import 'package:pocketeer_mobile/ui/views/auth/verify_email_screen.dart';
import 'package:pocketeer_mobile/ui/views/auth/change_password/change_password_screen.dart';
import 'package:pocketeer_mobile/ui/views/main_app_shell.dart';

class AppRouter {
  static const authGate = '/';
  static const verifyEmail = '/verify-email';
  static const main = '/main';
  static const changePassword = '/change-password';

  static Route<dynamic> generate(RouteSettings settings) {
    switch (settings.name) {
      case authGate:
        return MaterialPageRoute(builder: (_) => const AuthGate());
      case verifyEmail:
        return MaterialPageRoute(builder: (_) => const VerifyEmailScreen());
      case main:
        return MaterialPageRoute(builder: (_) => const MainAppShell());
      case changePassword:
        return MaterialPageRoute(builder: (_) => const ChangePasswordScreen());
      default:
        return MaterialPageRoute(builder: (_) => const AuthGate());
    }
  }
}
