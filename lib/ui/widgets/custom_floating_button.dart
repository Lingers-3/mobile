import 'package:flutter/material.dart';
import 'package:pocketeer_mobile/theme/app_theme.dart';

class CustomFloatingButton extends StatelessWidget {
  const CustomFloatingButton({
    super.key,
    required this.onPressed,
    this.heroTag,
  });

  final VoidCallback onPressed;
  final Object? heroTag;

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: onPressed,
      backgroundColor: AppColors.pink,
      child: const Icon(Icons.add, color: AppColors.primaryBackground),
      heroTag: heroTag,
    );
  }
}
