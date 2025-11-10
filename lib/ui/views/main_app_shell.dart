import 'package:flutter/material.dart';
import 'package:pocketeer_mobile/ui/views/inventory_screen.dart';
import 'package:pocketeer_mobile/ui/views/projects_screen.dart';
import 'package:pocketeer_mobile/ui/views/settings_screen.dart';
import 'package:pocketeer_mobile/ui/widgets/bottom_nav.dart';

class MainAppShell extends StatefulWidget {
  const MainAppShell({super.key});

  @override
  State<StatefulWidget> createState() {
    return _MainAppShellState();
  }
}

class _MainAppShellState extends State<MainAppShell> {
  int _selectedIndex = 0;
  static const List<Widget> _widgetsOptions = <Widget>[
    InventoryScreen(),
    ProjectsScreen(),
    SettingsScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: _widgetsOptions.elementAt(_selectedIndex)),
      bottomNavigationBar: BottomNav(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}
