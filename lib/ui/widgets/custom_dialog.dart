import 'package:flutter/material.dart';
import 'package:pocketeer_mobile/theme/app_theme.dart';

class CustomDialog extends StatelessWidget {
  const CustomDialog({
    super.key,
    required this.label,
    required this.confirmationText,
    required this.dialogFunction,
  });

  final String label;
  final String confirmationText;
  final Future<void> Function() dialogFunction;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.dialogBackground,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),

      title: Text(
        label,
        style: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.normal,
          color: AppColors.purple,
        ),
      ),
      content: SizedBox(
        width: 320,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              confirmationText,
              style: const TextStyle(color: Colors.white, fontSize: 13),
            ),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SizedBox(
                  width: 120,
                  child: OutlinedButton.icon(
                    onPressed: () => Navigator.of(context).pop(),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      side: const BorderSide(color: AppColors.purple),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    label: const Text(
                      'No',
                      style: TextStyle(fontSize: 18, color: AppColors.purple),
                    ),
                    icon: const Icon(
                      Icons.undo,
                      size: 20,
                      color: AppColors.purple,
                    ),
                  ),
                ),
                Container(
                  width: 120,
                  decoration: BoxDecoration(
                    gradient: AppColors.fadePurple,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: OutlinedButton.icon(
                    onPressed: dialogFunction,
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      side: const BorderSide(color: AppColors.purple),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    label: const Text(
                      'Yes',
                      style: TextStyle(fontSize: 18, color: Colors.white),
                    ),
                    icon: const Icon(
                      Icons.check,
                      size: 20,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
