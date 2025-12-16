import 'package:flutter/material.dart';
import 'package:pocketeer_mobile/data/models/item_types/item_type.dart';
import 'package:pocketeer_mobile/ui/widgets/picture_loader.dart';
import 'package:pocketeer_mobile/data/models/items/item.dart';
import 'package:pocketeer_mobile/theme/app_theme.dart';

class ProjectInventoryTile extends StatelessWidget {
  final ItemType itemType;
  final Item item;
  final VoidCallback onAdd;
  final VoidCallback onTap;

  const ProjectInventoryTile({
    super.key,
    required this.itemType,
    required this.item,
    required this.onAdd,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: ListTile(
        onTap: onTap,
        leading: _buildImage(),
        title: Text(
          item.description ?? itemType.name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: AppColors.purple,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          'Available: ${item.quantity} ${item.displayMeasurementUnit}',
          style: TextStyle(color: AppColors.cyan, fontSize: 12),
        ),
        trailing: IconButton(
          icon: const Icon(Icons.add_circle_outline, color: AppColors.pink),
          onPressed: onAdd,
          tooltip: 'Reserve',
        ),
      ),
    );
  }

  Widget _buildImage() {
    if (itemType.pictureId == null) {
      return _placeholder();
    }

    return PictureLoader(
      pictureId: itemType.pictureId!,
      size: 64,
      borderRadius: 12,
      placeholderIcon: const Icon(
        Icons.image,
        color: AppColors.purple,
        size: 40,
      ),
    );
  }

  Widget _placeholder() {
    return Container(
      width: 64,
      height: 64,
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Icon(Icons.image, color: AppColors.purple, size: 40),
    );
  }
}
