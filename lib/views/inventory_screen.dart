import 'package:flutter/material.dart';
import 'package:pocketeer_mobile/theme/app_theme.dart';

class InventoryScreen extends StatelessWidget {
  const InventoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryBackground,
      body: const Center(
        child: Text(
          'Inventory Screen',
          style: TextStyle(fontSize: 24, color: AppColors.pink),
        ),
      ),
    );
  }
}
