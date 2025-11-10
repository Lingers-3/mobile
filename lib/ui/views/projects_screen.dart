import 'package:flutter/material.dart';
import 'package:pocketeer_mobile/theme/app_theme.dart';

class ProjectsScreen extends StatelessWidget {
  const ProjectsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryBackground,
      body: const Center(
        child: Text(
          'Projects Screen',
          style: TextStyle(fontSize: 24, color: AppColors.pink),
        ),
      ),
    );
  }
}
