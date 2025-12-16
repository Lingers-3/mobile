import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:pocketeer_mobile/data/models/resource_specifications/resource_type.dart';
import 'package:pocketeer_mobile/providers/picture_provider.dart';
import 'package:pocketeer_mobile/ui/widgets/picture_loader.dart';
import 'package:provider/provider.dart';
import 'package:pocketeer_mobile/data/models/resource_specifications/resource_specification.dart';
import 'package:pocketeer_mobile/data/models/item_types/item_type.dart';
import 'package:pocketeer_mobile/theme/app_theme.dart';

class ResourceSpecificationCard extends StatelessWidget {
  final ItemType itemType;
  final ResourceSpecification specification;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const ResourceSpecificationCard({
    super.key,
    required this.itemType,
    required this.specification,
    this.onTap,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final reservations = specification.reservations ?? [];

    final double actualReserved = reservations.fold(
      0,
      (sum, r) => sum + r.reservedQuantity,
    );
    final double actualUsed = reservations.fold(
      0,
      (sum, r) => sum + r.usedQuantity,
    );

    // Візуальні налаштування
    final isTool = specification.resourceType == ResourceType.tool;
    final typeColor = isTool ? Colors.orange : Colors.blue;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            children: [
              // --- UPPER ROW: picture + name + resource type ---
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // IMAGE
                  _buildImage(),

                  const SizedBox(width: 12),

                  // Назва та бейдж типу
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          itemType.name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: typeColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(
                              color: typeColor.withValues(alpha: 0.3),
                            ),
                          ),
                          child: Text(
                            specification.resourceTypeLabel,
                            style: TextStyle(
                              color: typeColor,
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  Transform.translate(
                    offset: const Offset(8, 0),
                    child: PopupMenuButton<String>(
                      padding: EdgeInsets.zero,
                      color: AppColors.dialogBackground,
                      icon: const Icon(
                        Icons.more_vert,
                        color: AppColors.purple,
                      ),
                      onSelected: (value) {
                        switch (value) {
                          case 'edit':
                            onEdit?.call();
                            break;
                          case 'delete':
                            onDelete?.call();
                            break;
                        }
                      },
                      itemBuilder: (context) => [
                        if (onEdit != null)
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

              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8.0),
                child: Divider(height: 1),
              ),

              // --- Нижній рядок: Статистика ---
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildStatItem(
                    'Planned',
                    specification.plannedQuantity,
                    Colors.black87,
                  ),
                  _buildVerticalDivider(),
                  _buildStatItem(
                    'Reserved',
                    actualReserved,
                    Colors.blue.shade700,
                  ),
                  _buildVerticalDivider(),
                  _buildStatItem(
                    'Used',
                    actualUsed,
                    actualUsed > specification.plannedQuantity
                        ? Colors.red
                        : Colors.green.shade700,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, double value, Color color) {
    return Expanded(
      child: Column(
        children: [
          Text(
            label.toUpperCase(),
            style: TextStyle(
              fontSize: 10,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 2),
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: value
                      .toStringAsFixed(1)
                      .replaceAll(RegExp(r'\.0$'), ''), // 5.0 -> 5
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    fontFamily: 'Roboto', // Або ваш шрифт
                  ),
                ),
                TextSpan(
                  text: ' ${itemType.displayMeasurementUnit}',
                  style: TextStyle(
                    color: color.withValues(alpha: 0.7),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVerticalDivider() {
    return Container(height: 24, width: 1, color: Colors.grey.shade300);
  }

  Widget _buildImage() {
    final iconData = specification.resourceType == ResourceType.tool
        ? Icons.handyman
        : Icons.layers;

    final picId = itemType.pictureId;

    if (picId == null) {
      return _imageContainer(
        icon: Icon(iconData, size: 24, color: AppColors.purple),
      );
    }

    return PictureLoader(
      pictureId: picId,
      size: 50,
      borderRadius: 8,
      placeholderIcon: Icon(iconData, size: 24, color: AppColors.purple),
    );
  }

  Widget _imageContainer({
    ImageProvider? image,
    bool loading = false,
    Widget? icon,
  }) {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(8),
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
