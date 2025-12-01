import 'package:flutter/material.dart';
import 'package:pocketeer_mobile/theme/app_theme.dart';

class CustomDateInput extends StatelessWidget {
  final DateTime? selectedDate;
  final String label;
  final ValueChanged<DateTime?> onDateSelected;

  const CustomDateInput({
    super.key,
    required this.selectedDate,
    required this.label,
    required this.onDateSelected,
  });

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppColors.pink,
              onPrimary: AppColors.primaryBackground,
              surface: AppColors.primaryBackground,
              onSurface: AppColors.purple,
            ),
            dialogTheme: const DialogThemeData(
              backgroundColor: AppColors.primaryBackground,
            ),
          ),
          child: child!,
        );
      },
    );
    onDateSelected(picked);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AppColors.purple,
            fontWeight: FontWeight.w500,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: () => _selectDate(context),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
            decoration: BoxDecoration(
              color: AppColors.primaryBackground,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  selectedDate == null
                      ? 'Оберіть дату (Необов\'язково)'
                      : selectedDate!.toString().split(' ')[0],
                  style: TextStyle(
                    color: selectedDate == null
                        ? AppColors.purple.withOpacity(0.7)
                        : AppColors.purple,
                    fontSize: 16,
                  ),
                ),
                Icon(
                  Icons.calendar_today,
                  color: AppColors.purple.withOpacity(0.7),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
      ],
    );
  }
}
