import 'package:flutter/material.dart';
import 'package:pocketeer_mobile/data/models/item_types/item_type.dart';
import 'package:pocketeer_mobile/theme/app_theme.dart';
import 'package:pocketeer_mobile/data/models/unit.dart';
import 'package:pocketeer_mobile/providers/item_provider.dart';
import 'package:pocketeer_mobile/ui/widgets/picture_loader.dart';

class ItemTypeCard extends StatelessWidget {
  final ItemType itemType;
  final bool isSelected;

  // !!! ВИДАЛЕНО: imageUrl та pictureId (вони є в itemType) !!!
  // final String? imageUrl;
  // final int? pictureId;

  final ItemExpirationStatus expirationStatus;
  final bool isShortage;

  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final VoidCallback? onOpen;
  final VoidCallback? onDelete;

  final double totalQuantity;

  final bool showMenu;

  const ItemTypeCard({
    super.key,
    required this.itemType,
    required this.isSelected,
    // !!! ВИДАЛЕНО З КОНСТРУКТОРА !!!
    // required this.imageUrl,
    // this.pictureId,
    this.onTap,
    this.onLongPress,
    this.onOpen,
    this.onDelete,
    required this.totalQuantity,
    required this.expirationStatus,
    this.isShortage = false,
    this.showMenu = true,
    // !!! АРГУМЕНТИ ВИДАЛЕНО, ПЕРЕВІРТЕ ВСІ ВИКЛИКИ ItemTypeCard В КОДІ !!!
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
          boxShadow: [
            BoxShadow(
              color: AppColors.pink,
              blurRadius: 1,
              offset: Offset(1, 0),
            ),
          ],
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
            if (showMenu)
              Positioned(
                right: -9,
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
                  _buildImage(),

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
                          color: Colors.redAccent.withValues(alpha: 0.2),
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

  Widget _buildImage() {
    if (itemType.pictureId == null) {
      return _imageContainer(
        icon: const Icon(Icons.image, size: 40, color: AppColors.purple),
      );
    }

    return PictureLoader(
      pictureId: itemType.pictureId!,
      size: 140,
      borderRadius: 12,
      placeholderIcon: const Icon(
        Icons.image,
        size: 40,
        color: AppColors.purple,
      ),
    );
  }

  Widget _imageContainer({
    ImageProvider? image,
    bool loading = false,
    Widget? icon,
  }) {
    return Container(
      height: 140,
      width: 140,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.black26,
        image: image != null
            ? DecorationImage(image: image, fit: BoxFit.cover)
            : null,
      ),
      child: loading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.pink),
            )
          : image == null
          ? icon
          : null,
    );
  }
}
