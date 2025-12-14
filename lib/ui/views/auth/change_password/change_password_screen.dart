import 'package:flutter/material.dart';
import 'package:pocketeer_mobile/theme/app_theme.dart';
import 'package:pocketeer_mobile/ui/widgets/gradient_button.dart';
import 'change_password_controller.dart';
import '../../../widgets/password_rules_widget.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final controller = ChangePasswordController();
  bool _isLoading = false;

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    final success = await controller.changePassword(context);

    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(success ? '✅ Success' : '❌ Error')));
    if (success) Navigator.pop(context);
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Change Password'),
        backgroundColor: AppColors.primaryBackground,
        foregroundColor: AppColors.purple,
      ),
      backgroundColor: AppColors.primaryBackground,
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: controller.newPasswordController,
                obscureText: true,
                style: const TextStyle(color: AppColors.pink, fontSize: 16),
                cursorColor: AppColors.purple,
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  labelText: 'New password',
                  labelStyle: const TextStyle(color: AppColors.pink),
                  hintText: 'Enter your new password',
                  hintStyle: const TextStyle(color: AppColors.pink),
                  filled: true,
                  fillColor: Colors.transparent,
                  enabledBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: AppColors.purple),
                    borderRadius: BorderRadius.all(Radius.circular(12)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: AppColors.pink),
                    borderRadius: BorderRadius.all(Radius.circular(12)),
                  ),
                ),

                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Enter password';
                  }
                  if (value.length < 8) {
                    return 'Must contain at least 8 characters';
                  }
                  int complexity = 0;
                  if (RegExp(r'[a-z]').hasMatch(value)) complexity++;
                  if (RegExp(r'[A-Z]').hasMatch(value)) complexity++;
                  if (RegExp(r'\d').hasMatch(value)) complexity++;
                  if (RegExp(r'[!@#\$%^&*(),.?":{}|<>]').hasMatch(value)) {
                    complexity++;
                  }
                  if (complexity < 3) {
                    return 'Password must contain at least 3 of the following:\n'
                        '- lowercase letters\n'
                        '- uppercase letters\n'
                        '- numbers\n'
                        '- special characters';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              PasswordRulesWidget(
                hasMinLength: controller.hasMinLength,
                hasLower: controller.hasLower,
                hasUpper: controller.hasUpper,
                hasNumber: controller.hasNumber,
                hasSpecial: controller.hasSpecial,
                complexity: controller.complexity,
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: controller.confirmPasswordController,
                obscureText: true,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Confirm password',
                  labelStyle: const TextStyle(color: AppColors.pink),
                  focusedBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: AppColors.pink),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: AppColors.purple),
                    borderRadius: BorderRadius.all(Radius.circular(12)),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: (value) {
                  if (value != controller.newPasswordController.text) {
                    return 'Passwords do not match';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 30),
              _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(color: AppColors.pink),
                    )
                  : GradientButton(
                      label: 'Change Password',
                      onPressed: _handleSubmit,
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
