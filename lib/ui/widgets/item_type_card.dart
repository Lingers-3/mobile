import 'package:flutter/material.dart';
import 'package:pocketeer_mobile/data/models/item_type.dart';
import 'package:pocketeer_mobile/theme/app_theme.dart';

class ItemTypeCard extends StatelessWidget {
  final ItemType itemType;
  final bool isSelected;
  final String? imageUrl;

  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final VoidCallback? onOpen;
  final VoidCallback? onDelete;

  const ItemTypeCard({
    super.key,
    required this.itemType,
    required this.isSelected,
    required this.imageUrl,
    this.onTap,
    this.onLongPress,
    this.onOpen,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.dialogBackground,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.pink : Colors.transparent,
            width: 2,
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              right: 0,
              child: PopupMenuButton<String>(
                color: AppColors.dialogBackground,
                icon: const Icon(Icons.more_vert, color: AppColors.purple),
                onSelected: (value) {
                  switch (value) {
                    case 'info':
                      if (onOpen != null) onOpen!();
                      break;
                    case 'delete':
                      if (onDelete != null) onDelete!();
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
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // картинка або іконка
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
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
