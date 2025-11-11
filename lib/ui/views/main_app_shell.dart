import 'package:flutter/material.dart';
import 'package:pocketeer_mobile/ui/views/inventory_screen.dart';
import 'package:pocketeer_mobile/ui/views/projects_screen.dart';
import 'package:pocketeer_mobile/ui/views/settings_screen.dart';
import 'package:pocketeer_mobile/ui/widgets/bottom_nav.dart';

class MainAppShell extends StatefulWidget {
  const MainAppShell({super.key});

  @override
  State<MainAppShell> createState() => _MainAppShellState();
}

class _MainAppShellState extends State<MainAppShell> {
  final PageController _pageController = PageController();
  int _selectedIndex = 0;

  static const List<Widget> _widgetsOptions = <Widget>[
    InventoryScreen(),
    ProjectsScreen(),
    SettingsScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInQuint,
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        physics: ClampingScrollPhysics(),
        onPageChanged: (index) => setState(() => _selectedIndex = index),
        children: _widgetsOptions,
      ),
      bottomNavigationBar: BottomNav(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}
