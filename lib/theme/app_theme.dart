import 'package:flutter/material.dart';

class AppColors {
  static const Color primaryBackground = Color.fromARGB(255, 40, 42, 54);
  static const Color navBarBackground = Color.fromARGB(200, 46, 46, 60);
  static const Color dialogBackground = Color.fromARGB(255, 32, 34, 46);

  static const Color pink = Color.fromARGB(255, 255, 121, 198);
  static const Color cyan = Color.fromARGB(255, 139, 233, 253);
  static const Color purple = Color.fromARGB(255, 177, 167, 252);
  static const LinearGradient fadePurple = LinearGradient(
    colors: [
      Color.fromARGB(255, 177, 92, 164),
      Color.fromARGB(255, 142, 92, 196),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

final ThemeData appTheme = ThemeData(
  scaffoldBackgroundColor: AppColors.primaryBackground,
  appBarTheme: const AppBarTheme(
    backgroundColor: AppColors.primaryBackground,
    scrolledUnderElevation: 0,
  ),

  switchTheme: SwitchThemeData(
    thumbColor: WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.selected)) {
        return AppColors.pink; // ON “точка”
      }
      return AppColors.primaryBackground; // OFF “точка”
    }),
    trackColor: WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.selected)) {
        return AppColors.pink.withValues(alpha: 0.7); // ON “дорожка”
      }
      return AppColors.purple.withValues(alpha: 0.5); // OFF “дорожка”
    }),
    trackOutlineColor: WidgetStateProperty.resolveWith((states) {
      return AppColors.dialogBackground;
    }),
  ),

  brightness: Brightness.dark,
  useMaterial3: true,
  bottomNavigationBarTheme: const BottomNavigationBarThemeData(
    backgroundColor: AppColors.primaryBackground,
    selectedItemColor: AppColors.pink,
    unselectedItemColor: AppColors.pink,
    showSelectedLabels: true,
    showUnselectedLabels: true,
    type: BottomNavigationBarType.fixed,
  ),
);
