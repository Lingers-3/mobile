import 'package:flutter/material.dart';
import 'package:pocketeer_mobile/theme/app_theme.dart';

class PasswordRulesWidget extends StatelessWidget {
  final bool hasMinLength;
  final bool hasLower;
  final bool hasUpper;
  final bool hasNumber;
  final bool hasSpecial;
  final int complexity;

  const PasswordRulesWidget({
    super.key,
    required this.hasMinLength,
    required this.hasLower,
    required this.hasUpper,
    required this.hasNumber,
    required this.hasSpecial,
    required this.complexity,
  });

  Widget _rule(String text, bool satisfied) {
    return Row(
      children: [
        Icon(
          satisfied ? Icons.check_circle : Icons.cancel,
          color: satisfied ? AppColors.pink : AppColors.purple,
          size: 18,
        ),
        const SizedBox(width: 8),
        Text(
          text,
          style: TextStyle(
            color: satisfied ? AppColors.pink : AppColors.purple,
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _rule('At least 8 characters', hasMinLength),
        _rule('Lower case letters (a–z)', hasLower),
        _rule('Upper case letters (A–Z)', hasUpper),
        _rule('Numbers (0–9)', hasNumber),
        _rule('Special Characters (!@#\$...)', hasSpecial),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: (complexity / 4).clamp(0.0, 1.0),
          backgroundColor: AppColors.primaryBackground,
          color: AppColors.pink,
          minHeight: 6,
        ),
      ],
    );
  }
}
