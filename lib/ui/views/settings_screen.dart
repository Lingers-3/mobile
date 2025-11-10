import 'package:flutter/material.dart';
import 'package:pocketeer_mobile/data/services/auth_service.dart';
import 'package:pocketeer_mobile/theme/app_theme.dart';
import 'package:pocketeer_mobile/ui/widgets/delete_account_confirmation_dialog.dart';
import 'package:pocketeer_mobile/ui/widgets/logout_confirmation_dialog.dart';
import 'package:pocketeer_mobile/ui/widgets/setting_button.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<StatefulWidget> createState() {
    return _SettingsScreenState();
  }
}

class _SettingsScreenState extends State<SettingsScreen> {
  final authService = AuthService();

  void _showLogoutConfirmDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return LogoutConfirmationDialog();
      },
    );
  }

  void _showDeleteAccountDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return DeleteAccountDialog();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final userEmail = authService.credentials?.user.email ?? 'Unknown';

    return Scaffold(
      backgroundColor: AppColors.primaryBackground,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          mainAxisSize: MainAxisSize.min,

          children: [
            SizedBox(height: 80),
            Text(
              userEmail,
              style: TextStyle(fontSize: 26, color: AppColors.purple),
            ),
            SizedBox(height: 40),
            SettingButton(buttonText: 'Change Password', buttonFunction: () {}),
            SizedBox(height: 40),
            SettingButton(
              buttonText: 'Logout',
              buttonFunction: _showLogoutConfirmDialog,
            ),
            SizedBox(height: 40),
            SettingButton(
              buttonText: 'Delete Account',
              buttonFunction: _showDeleteAccountDialog,
            ),
          ],
        ),
      ),
    );
  }
}
