import 'package:flutter/material.dart';
import 'package:pocketeer_mobile/data/services/auth_service.dart';
import 'package:pocketeer_mobile/ui/views/auth/auth_gate.dart';
import 'package:pocketeer_mobile/ui/widgets/custom_dialog.dart';

class DeleteAccountDialog extends StatelessWidget {
  const DeleteAccountDialog({super.key});

  Future<void> _handleDelete(BuildContext context) async {
    final authService = AuthService();

    await authService.deleteAccount(context);

    await Future.delayed(const Duration(milliseconds: 800));

    if (context.mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const AuthGate()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return CustomDialog(
      label: 'Delete Account',
      confirmationText:
          'Are you sure you want to permanently delete your account?',
      dialogFunction: () => _handleDelete(context),
    );
  }
}
