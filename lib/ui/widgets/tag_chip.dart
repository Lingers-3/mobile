import 'package:flutter/material.dart';
import 'package:pocketeer_mobile/theme/app_theme.dart';

class TagChip extends StatelessWidget {
  final String label;
  final String? color;
  final bool selected;

  const TagChip({
    super.key,
    required this.label,
    required this.selected,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final tagColor = color != null
        ? Color(int.parse("0xff$color"))
        : AppColors.pink;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: selected ? tagColor.withOpacity(.3) : AppColors.dialogBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: selected ? tagColor : AppColors.purple.withOpacity(.4),
          width: 1.6,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(color: tagColor, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),

          Text(
            label,
            style: TextStyle(
              color: selected ? tagColor : AppColors.pink,
              fontWeight: FontWeight.w600,
            ),
          ),

          if (selected)
            const Padding(
              padding: EdgeInsets.only(left: 6),
              child: Icon(Icons.check, size: 16, color: AppColors.pink),
            ),
        ],
      ),
    );
  }
}

