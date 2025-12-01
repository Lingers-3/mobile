import 'package:flutter/material.dart';
import 'package:pocketeer_mobile/data/models/item_types/item_type.dart';
import 'package:pocketeer_mobile/theme/app_theme.dart';
import 'package:pocketeer_mobile/data/models/unit.dart';
import 'package:pocketeer_mobile/providers/item_provider.dart';

class ItemTypeCard extends StatelessWidget {
  final ItemType itemType;
  final bool isSelected;
  final String? imageUrl;
  final ItemExpirationStatus expirationStatus;
  final bool isShortage;

  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final VoidCallback? onOpen;
  final VoidCallback? onDelete;

  final double totalQuantity;

  const ItemTypeCard({
    super.key,
    required this.itemType,
    required this.isSelected,
    required this.imageUrl,
    this.onTap,
    this.onLongPress,
    this.onOpen,
    this.onDelete,
    required this.totalQuantity,
    required this.expirationStatus,
    this.isShortage = false,
  });

  @override
  Widget build(BuildContext context) {
    final unit = findUnit(itemType.displayMeasurementUnit);
    Color borderColor;
    switch (expirationStatus) {
      case ItemExpirationStatus.expired:
        borderColor = Colors.redAccent;
        break;
      case ItemExpirationStatus.expiring:
        borderColor = Colors.orangeAccent;
        break;
      case ItemExpirationStatus.none:
        borderColor = Colors.transparent;
        break;
    }

    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.dialogBackground,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderColor, width: 2),
        ),
        child: Stack(
          children: [
            if (isSelected)
              Container(
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.35),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Center(
                  child: Icon(
                    Icons.check_circle,
                    size: 48,
                    color: Colors.white,
                  ),
                ),
              ),
            Positioned(
              right: 0,
              child: PopupMenuButton<String>(
                color: AppColors.dialogBackground,
                icon: const Icon(Icons.more_vert, color: AppColors.purple),
                onSelected: (value) {
                  switch (value) {
                    case 'info':
                      onOpen?.call();
                      break;
                    case 'delete':
                      onDelete?.call();
                      break;
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'info',
                    child: Text(
                      "Show info",
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

            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // IMAGE
                  Container(
                    height: 140,
                    width: 140,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: Colors.black26,
                      image: imageUrl != null
                          ? DecorationImage(
                              image: NetworkImage(imageUrl!),
                              fit: BoxFit.cover,
                            )
                          : null,
                    ),
                    child: imageUrl == null
                        ? const Icon(
                            Icons.image,
                            color: AppColors.purple,
                            size: 40,
                          )
                        : null,
                  ),

                  const SizedBox(height: 12),

                  Text(
                    itemType.name,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: AppColors.purple,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  Text(
                    '${totalQuantity.toStringAsFixed(2)} ${unit.label}',
                    style: TextStyle(
                      color: isShortage ? Colors.redAccent : AppColors.pink,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (isShortage)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.redAccent.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.redAccent),
                        ),
                        child: const Text(
                          'Low stock',
                          style: TextStyle(
                            color: Colors.redAccent,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
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
