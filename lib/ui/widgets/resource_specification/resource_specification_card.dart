import 'package:flutter/material.dart';
import 'package:pocketeer_mobile/data/models/resource_specifications/resource_type.dart';
import 'package:pocketeer_mobile/providers/item_type_provider.dart';
import 'package:pocketeer_mobile/providers/project_provider.dart';
import 'package:provider/provider.dart';
import 'package:pocketeer_mobile/data/models/resource_specifications/resource_specification.dart';
import 'package:pocketeer_mobile/data/models/item_types/item_type.dart';
import 'package:pocketeer_mobile/theme/app_theme.dart';

class ResourceSpecificationCard extends StatefulWidget {
  final int projectId;
  final int specificationId;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const ResourceSpecificationCard({
    super.key,
    required this.projectId,
    required this.specificationId,
    this.onTap,
    this.onEdit,
    this.onDelete,
  });

  @override
  State<ResourceSpecificationCard> createState() =>
      _ResourceSpecificationCard();
}

class _ResourceSpecificationCard extends State<ResourceSpecificationCard> {
  @override
  Widget build(BuildContext context) {
    // --- GET SPECIFICATION ---
    final specification = context
        .select<ProjectProvider, ResourceSpecification?>(
          (p) => p
              .getById(widget.projectId)
              ?.specifications
              ?.where((s) => s.id == widget.specificationId)
              .firstOrNull,
        );

    if (specification == null) {
      // TODO(saloway): handle gracefuly
      return const Center(child: Text('Specification not found!'));
    }

    final reservations = specification.reservations ?? [];

    final itemType = context.select<ItemTypeProvider, ItemType>(
      (itp) =>
          itp.itemTypes.firstWhere((it) => it.id == specification.itemTypeId),
    );

    final String unit = itemType.displayMeasurementUnit;
    final String name = itemType.name;

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
    final typeIcon = isTool ? Icons.handyman : Icons.layers;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: widget.onTap,
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
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(8),
                      image: itemType.pictureId != null
                          ? null // Тут можна додати NetworkImage, якщо реалізувати завантаження фото
                          : null,
                    ),
                    child: itemType.pictureId == null
                        ? Icon(typeIcon, color: typeColor, size: 28)
                        : null,
                  ),
                  const SizedBox(width: 12),

                  // Назва та бейдж типу
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
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
                            widget.onEdit?.call();
                            break;
                          case 'delete':
                            widget.onDelete?.call();
                            break;
                        }
                      },
                      itemBuilder: (context) => [
                        if (widget.onEdit != null)
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
                    unit,
                    Colors.black87,
                  ),
                  _buildVerticalDivider(),
                  _buildStatItem(
                    'Reserved',
                    actualReserved,
                    unit,
                    Colors.blue.shade700,
                  ),
                  _buildVerticalDivider(),
                  _buildStatItem(
                    'Used',
                    actualUsed,
                    unit,
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

  Widget _buildStatItem(String label, double value, String unit, Color color) {
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
                  text: ' $unit',
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
}
