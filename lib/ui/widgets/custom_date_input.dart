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
    if (picked != null) {
      final DateTime fixedDate = DateTime.utc(
        picked.year,
        picked.month,
        picked.day,
      );
      onDateSelected(fixedDate);
    } else {
      onDateSelected(null);
    }
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
        const SizedBox(height: 2),

        InkWell(
          onTap: () => _selectDate(context),
          child: InputDecorator(
            decoration: InputDecoration(
              labelText: '',
              labelStyle: const TextStyle(color: AppColors.purple),
              border: const OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(12)), //
                borderSide: BorderSide(color: AppColors.purple),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: const BorderRadius.all(Radius.circular(12)),
                borderSide: BorderSide(
                  color: AppColors.purple.withOpacity(0.5),
                ),
              ),
              focusedBorder: const OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(12)),
                borderSide: BorderSide(color: AppColors.pink), // Активний колір
              ),
              contentPadding: const EdgeInsets.symmetric(
                vertical: 16,
                horizontal: 12,
              ),

              suffixIcon: selectedDate != null
                  ? IconButton(
                      icon: const Icon(Icons.clear, color: AppColors.purple),
                      onPressed: () => onDateSelected(null),
                    )
                  : const Icon(Icons.calendar_today, color: AppColors.purple),
            ),

            // Вміст поля
            child: Text(
              selectedDate != null ? _formatDate(selectedDate!)! : 'Not picked',
              style: TextStyle(
                color: selectedDate == null
                    ? AppColors.purple.withOpacity(0.7)
                    : AppColors.pink,
                fontSize: 16,
              ),
            ),
          ),
        ),
        SizedBox(height: 16),
      ],
    );
  }
}

String? _formatDate(DateTime? date) {
  if (date == null) return null;
  return '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year}';
}
