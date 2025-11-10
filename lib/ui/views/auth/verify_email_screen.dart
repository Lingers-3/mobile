import 'package:flutter/material.dart';
import 'package:pocketeer_mobile/routes/app_router.dart';
import 'package:pocketeer_mobile/theme/app_theme.dart';

class VerifyEmailScreen extends StatelessWidget {
  const VerifyEmailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryBackground,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.email_outlined, size: 72, color: AppColors.cyan),
              const SizedBox(height: 24),
              const Text(
                'Check your email',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppColors.pink,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'We have sent you an email confirmation sheet.\nAfter confirmation, click below:',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.cyan),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () =>
                    Navigator.pushReplacementNamed(context, AppRouter.authGate),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBackground,
                  shadowColor: AppColors.cyan,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 12,
                  ),
                ),
                child: const Text(
                  'Check confirmation',
                  style: TextStyle(color: AppColors.pink),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
