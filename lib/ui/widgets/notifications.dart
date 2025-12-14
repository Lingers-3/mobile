import 'package:flutter/material.dart';
import 'package:pocketeer_mobile/theme/app_theme.dart';

class Notifications extends StatefulWidget {
  const Notifications({super.key});

  @override
  State<Notifications> createState() => _NotificationsState();
}

class _NotificationsState extends State<Notifications> {
  bool _expirationEnabled = false;
  bool _deadlineEnabled = false;
  bool _thresholdEnabled = false;
  bool _insufficientEnabled = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SwitchListTile(
          title: const Text(
            'Notify on Expiration',
            style: TextStyle(color: AppColors.purple, fontSize: 24),
          ),

          value: _expirationEnabled,
          onChanged: (v) => setState(() => _expirationEnabled = v),
        ),
        SwitchListTile(
          title: const Text(
            'Notify on Deadline',
            style: TextStyle(color: AppColors.purple, fontSize: 24),
          ),
          value: _deadlineEnabled,
          onChanged: (v) => setState(() => _deadlineEnabled = v),
        ),
        SwitchListTile(
          title: const Text(
            'Notify on Threshold',
            style: TextStyle(color: AppColors.purple, fontSize: 24),
          ),
          value: _thresholdEnabled,
          onChanged: (v) => setState(() => _thresholdEnabled = v),
        ),
        SwitchListTile(
          title: const Text(
            'Notify on Insufficient',
            style: TextStyle(color: AppColors.purple, fontSize: 24),
          ),
          value: _insufficientEnabled,
          onChanged: (v) => setState(() => _insufficientEnabled = v),
        ),
      ],
    );
  }
}
