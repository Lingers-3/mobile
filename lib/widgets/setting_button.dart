import 'package:flutter/material.dart';
import 'package:pocketeer_mobile/theme/app_theme.dart';

class SettingButton extends StatelessWidget {
  final String buttonText;
  final void Function() buttonFunction;

  const SettingButton({
    super.key,
    required this.buttonText,
    required this.buttonFunction,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: buttonFunction,
      style: OutlinedButton.styleFrom(
        minimumSize: Size(200, 50),
        side: BorderSide(color: AppColors.purple),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      child: Text(buttonText, style: TextStyle(color: AppColors.purple)),
    );
  }
}
