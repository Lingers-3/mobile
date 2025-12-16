import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:pocketeer_mobile/data/models/item_types/item_type.dart';
import 'package:pocketeer_mobile/data/models/items/item.dart';
import 'package:pocketeer_mobile/providers/picture_provider.dart';
import 'package:pocketeer_mobile/providers/project_provider.dart';
import 'package:pocketeer_mobile/ui/widgets/picture_loader.dart';
import 'package:provider/provider.dart';
import 'package:pocketeer_mobile/theme/app_theme.dart';
import 'package:pocketeer_mobile/data/models/resource_reservations/resource_reservation.dart';
import 'package:pocketeer_mobile/ui/widgets/resource_reservation/resource_reservation_edit_dialog.dart';

class ResourceReservationCard extends StatelessWidget {
  final int projectId;
  final int specificationId;
  final ItemType itemType;
  final Item item;
  final ResourceReservation reservation;

  const ResourceReservationCard({
    super.key,
    required this.projectId,
    required this.specificationId,
    required this.itemType,
    required this.item,
    required this.reservation,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Зображення
            _buildImage(),

            const SizedBox(width: 12),

            // Основна інформація
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),
                  _buildInfoRow(
                    'Reserved:',
                    reservation.reservedQuantity,
                    item.displayMeasurementUnit,
                    Colors.blue,
                  ),
                  const SizedBox(height: 4),
                  _buildInfoRow(
                    'Used:',
                    reservation.usedQuantity,
                    item.displayMeasurementUnit,
                    Colors.green,
                  ),
                ],
              ),
            ),

            // Меню дій "..."
            PopupMenuButton<String>(
              onSelected: (value) async {
                if (value == 'edit') {
                  showDialog(
                    context: context,
                    builder: (ctx) => ResourceReservationEditDialog(
                      reservation: reservation,
                      onApply: (newReserved, newUsed) async {
                        await context
                            .read<ProjectProvider>()
                            .updateResourceReservation(
                              projectId,
                              specificationId,
                              reservation.id,
                              newReserved,
                              newUsed,
                            );
                      },
                    ),
                  );
                } else if (value == 'delete') {
                  await context.read<ProjectProvider>().freeItem(
                    projectId,
                    specificationId,
                    reservation.id,
                  );
                }
              },
              itemBuilder: (BuildContext context) => [
                const PopupMenuItem(
                  value: 'edit',
                  child: Row(
                    children: [
                      Icon(Icons.edit, size: 20),
                      SizedBox(width: 8),
                      Text('Change'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete, size: 20, color: Colors.red),
                      SizedBox(width: 8),
                      Text('Delete', style: TextStyle(color: Colors.red)),
                    ],
                  ),
                ),
              ],
              icon: const Icon(Icons.more_vert),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(
    String label,
    double value,
    String unit,
    Color valueColor,
  ) {
    return Row(
      children: [
        Text(
          label,
          style: const TextStyle(color: AppColors.cyan, fontSize: 12),
        ),
        const SizedBox(width: 8),
        Text(
          '${value.toStringAsFixed(2)} $unit',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: valueColor,
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Widget _buildImage() {
    if (itemType.pictureId == null) {
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

    return PictureLoader(
      pictureId: itemType.pictureId!,
      size: 64,
      borderRadius: 12,
    );
  }

  Widget _imageContainer({
    ImageProvider? image,
    bool loading = false,
    Widget? icon,
  }) {
    return Container(
      height: 64,
      width: 64,
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
