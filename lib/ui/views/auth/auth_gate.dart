import 'package:flutter/material.dart';
import 'package:pocketeer_mobile/data/services/auth_service.dart';
import 'package:pocketeer_mobile/routes/app_router.dart';
import 'package:pocketeer_mobile/theme/app_theme.dart';
import 'package:pocketeer_mobile/ui/views/main_app_shell.dart';

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
    Future.microtask(_handleAuthFlow);
  }

  Future<void> _handleAuthFlow() async {
    if (!mounted) return;

    setState(() => _status = AuthFlowStatus.checking);

    final result = await _authService.login();

    if (!mounted) return;

    switch (result) {
      case AuthResult.success:
        setState(() => _status = AuthFlowStatus.loggedIn);
        break;

      case AuthResult.emailNotVerified:
        if (!mounted) return;
        Navigator.pushReplacementNamed(context, AppRouter.verifyEmail);
        break;

      case AuthResult.error:
        await Future.delayed(const Duration(seconds: 2));
        if (!mounted) return;
        _handleAuthFlow();
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_status == AuthFlowStatus.loggedIn) {
      return const MainAppShell();
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
              'Checking authorization...',
              style: TextStyle(fontSize: 18, color: AppColors.pink),
            ),
            SizedBox(height: 8),
            Text(
              'You will be automatically redirected in the browser.',
              style: TextStyle(fontSize: 14, color: AppColors.cyan),
            ),
          ],
        ),
      ),
    );
  }
}
