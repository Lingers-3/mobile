import 'package:flutter/material.dart';
import 'package:pocketeer_mobile/data/models/items/item.dart';
import 'package:pocketeer_mobile/theme/app_theme.dart';
import 'package:pocketeer_mobile/ui/views/inventory/item_screens/show_item_screen.dart';

class ItemCard extends StatelessWidget {
  final Item item;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const ItemCard({
    super.key,
    required this.item,
    required this.onEdit,
    required this.onDelete,
  });

  bool get isExpired =>
      item.expirationDate != null &&
      item.expirationDate!.isBefore(DateTime.now());

  bool get isExpiringSoon {
    if (item.expirationDate == null) return false;
    final days = item.expirationDate!.difference(DateTime.now()).inDays;
    return days >= 0 && days <= 7;
  }

  Color get borderColor {
    if (isExpired) return Colors.redAccent;
    if (isExpiringSoon) return Colors.orangeAccent;
    return AppColors.dialogBackground;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => ShowItemScreen(item: item)),
      ),

      child: Container(
        decoration: BoxDecoration(
          color: AppColors.primaryBackground,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: borderColor,
            width: isExpired || isExpiringSoon ? 3 : 1,
          ),
        ),
        child: Column(
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(12),
                ),
                child: Container(
                  color: AppColors.dialogBackground,
                  child: const Center(
                    child: Icon(Icons.image, size: 70, color: AppColors.purple),
                  ),
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Text(
                '${item.quantity} ${item.displayMeasurementUnit}',
                style: const TextStyle(
                  color: AppColors.pink,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            Align(
              alignment: Alignment.topRight,
              child: PopupMenuButton<String>(
                color: AppColors.dialogBackground,
                icon: const Icon(Icons.more_vert, color: AppColors.purple),
                onSelected: (value) {
                  switch (value) {
                    case 'edit':
                      onEdit();
                      break;
                    case 'delete':
                      onDelete();
                      break;
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'edit',
                    child: Text(
                      "Edit",
                      style: TextStyle(color: AppColors.pink),
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Text(
                      "Delete",
                      style: TextStyle(color: AppColors.cyan),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

