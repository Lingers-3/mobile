import 'package:flutter/material.dart';
import 'package:pocketeer_mobile/theme/app_theme.dart';
import 'package:pocketeer_mobile/ui/widgets/custom_text_field.dart';

class CustomFilterDrawer extends StatelessWidget {
  final String currentSearchQuery;
  final String currentSortCriteria;
  final ValueChanged<String?> onSortChanged;
  final TextEditingController searchController;
  final double widthFactor;
  // *** 1. НОВЕ ПОЛЕ ДЛЯ ОБРОБКИ ПОШУКУ ***
  final ValueChanged<String>? onSearchChanged;

  const CustomFilterDrawer({
    super.key,
    required this.currentSearchQuery,
    required this.currentSortCriteria,
    required this.onSortChanged,
    required this.searchController,
    this.widthFactor = 0.5,
    // *** 2. ВИМАГАЄМО ЙОГО В КОНСТРУКТОРІ ***
    this.onSearchChanged,
  });

  Widget _buildSortOption(String title, String criteria) {
    return RadioListTile<String>(
      title: Text(title),
      value: criteria,
      groupValue: currentSortCriteria,
      onChanged: onSortChanged,
      dense: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(
      widthFactor: widthFactor,
      alignment: Alignment.centerLeft,
      child: Drawer(
        elevation: 10.0,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 50),

              CustomTextField(
                controller: searchController,
                labelText: 'Name Searching',
                // *** 3. ПЕРЕДАЄМО КОЛБЕК В CustomTextField ***
                onChanged: onSearchChanged,
              ),

              const SizedBox(height: 24),

              const Text(
                'Sorting',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.pink,
                ),
              ),
              _buildSortOption('Name (A-Z)', 'name_asc'),
              _buildSortOption('Name (Z-A)', 'name_desc'),

              _buildSortOption('Creation Date (Newest)', 'date_desc'),
              _buildSortOption('Creation Date (Oldest)', 'date_asc'),

              const SizedBox(height: 50),
              Center(
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Close'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
