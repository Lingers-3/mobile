import 'package:flutter/material.dart';

class AppColors {
  static const Color primaryBackground = Color.fromARGB(255, 40, 42, 54);

  static const Color pink = Color.fromARGB(255, 255, 121, 198);
  static const Color cyan = Color.fromARGB(255, 139, 233, 253);
}

final ThemeData appTheme = ThemeData(
  scaffoldBackgroundColor: AppColors.primaryBackground,
  brightness: Brightness.dark,
  bottomNavigationBarTheme: const BottomNavigationBarThemeData(
    backgroundColor: AppColors.primaryBackground,
    selectedItemColor: AppColors.pink,
    unselectedItemColor: AppColors.pink,
    showSelectedLabels: true,
    showUnselectedLabels: true,
    type: BottomNavigationBarType.fixed,
  ),
);
