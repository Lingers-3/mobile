import 'package:flutter/material.dart';
import 'package:pocketeer_mobile/theme/app_theme.dart';
import '../services/auth_service.dart';
import 'home_screen.dart';

enum AuthFlowStatus { checking, loggedIn }

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  final AuthService _authService = AuthService();
  AuthFlowStatus _status = AuthFlowStatus.checking;

  @override
  void initState() {
    super.initState();
    _handleAuthFlow();
  }

  void _handleAuthFlow() async {
    if (_status != AuthFlowStatus.checking) {
      setState(() {
        _status = AuthFlowStatus.checking;
      });
    }
    if (_authService.isAuthenticated) {
      if (mounted) {
        setState(() {
          _status = AuthFlowStatus.loggedIn;
        });
      }
      return;
    }
    final success = await _authService.login();
    if (mounted) {
      if (success) {
        setState(() {
          _status = AuthFlowStatus.loggedIn;
        });
      } else {
        await Future.delayed(const Duration(seconds: 2));
        _handleAuthFlow();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_status == AuthFlowStatus.loggedIn) {
      return const HomeScreen();
    }

    return const Scaffold(
      backgroundColor: AppColors.primaryBackground,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,

          children: [
            CircularProgressIndicator(color: AppColors.pink),
            SizedBox(height: 20),
            Text(
              'Перевірка авторизації...',
              style: TextStyle(fontSize: 18, color: AppColors.pink),
            ),
            SizedBox(height: 8),
            Text(
              'Вас буде автоматично перенаправлено у браузер.',
              style: TextStyle(fontSize: 14, color: AppColors.cyan),
            ),
          ],
        ),
      ),
    );
  }
}
