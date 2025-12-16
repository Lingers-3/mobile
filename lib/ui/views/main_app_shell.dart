import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:pocketeer_mobile/core/constants/app_constants.dart';
import 'package:pocketeer_mobile/ui/views/inventory/inventory_screen.dart';
import 'package:pocketeer_mobile/ui/views/projects/projects_screen.dart';
import 'package:pocketeer_mobile/ui/views/settings/settings_screen.dart';
import 'package:pocketeer_mobile/ui/widgets/bottom_nav.dart';

class MainAppShell extends StatefulWidget {
  const MainAppShell({super.key});

  @override
  State<MainAppShell> createState() => _MainAppShellState();
}

class _MainAppShellState extends State<MainAppShell> {
  final PageController _pageController = PageController();
  int _selectedIndex = 0;

  static List<Widget> _widgetsOptions = <Widget>[
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
  void initState() {
    super.initState();
    _widgetsOptions.add(
      // '${AppConstants.apiBaseUrl}/pictures/e87e676ce683804c6afedf9b01d1ba0122f0ed1feb35b450de5b17df14f3971f'
      Image.network(
        'https://pocketeer-api.linerds.us/pictures/e87e676ce683804c6afedf9b01d1ba0122f0ed1feb35b450de5b17df14f3971f.jpg',
        width: 100,
        height: 100,
        fit: BoxFit.cover,
        // Простий лоадер
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return const Center(child: CircularProgressIndicator());
        },
        // Проста обробка помилок
        errorBuilder: (context, error, stackTrace) {
          print('DA FUCKING ERROR: $error');
          return const Icon(Icons.error, color: Colors.red);
        },
      ),
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
