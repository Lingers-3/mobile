import 'package:flutter/material.dart';
// Переконайтеся, що цей шлях правильний для вашої теми
import 'package:pocketeer_mobile/theme/app_theme.dart';

class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String labelText;
  final String? hintText;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;
  final int maxLines;

  const CustomTextField({
    super.key,
    required this.controller,
    required this.labelText,
    this.hintText,
    this.keyboardType = TextInputType.text,
    this.validator,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      style: const TextStyle(
        color: AppColors.purple,
      ), // Колір тексту, що вводиться
      validator: validator,
      decoration: InputDecoration(
        labelText: labelText,
        hintText: hintText,
        hintStyle: TextStyle(color: AppColors.pink.withOpacity(0.7)),

        // Стилістика для фону і рамок
        filled: true,
        fillColor: AppColors.primaryBackground, // Темний фон для поля
        // Нормальний стан
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: AppColors.purple,
          ), // Прибираємо видиму рамку, залишаємо фон
        ),

        // Фокус (коли користувач друкує)
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: AppColors.pink, // Рожева рамка при фокусі
            width: 2.0,
          ),
        ),

        // Стиль для label (піднімається нагору)
        labelStyle: const TextStyle(color: AppColors.purple),
        floatingLabelStyle: const TextStyle(
          color: AppColors.pink, // Рожевий колір піднятого label
          fontWeight: FontWeight.bold,
        ),

        contentPadding: EdgeInsets.symmetric(
          vertical: maxLines > 1 ? 16.0 : 18.0,
          horizontal: 12.0,
        ),
      ),
    );
  }
}
