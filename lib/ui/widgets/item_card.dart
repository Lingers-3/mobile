import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:pocketeer_mobile/data/models/items/item.dart';
import 'package:pocketeer_mobile/providers/item_type_provider.dart';
import 'package:pocketeer_mobile/providers/picture_provider.dart';
import 'package:pocketeer_mobile/theme/app_theme.dart';
import 'package:pocketeer_mobile/ui/views/inventory/item_screens/show_item_screen.dart';
import 'package:provider/provider.dart';

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

  Widget _buildImage(BuildContext context) {
    final placeholder = const Center(
      child: Icon(Icons.image, size: 70, color: AppColors.purple),
    );

    final pictureId = context.select<ItemTypeProvider, int?>((provider) {
      final idx = provider.itemTypes.indexWhere((t) => t.id == item.itemTypeId);
      if (idx == -1) return null;
      return provider.itemTypes[idx].pictureId;
    });

    if (pictureId == null) return placeholder;

    final pictureProvider = context.read<PictureProvider>();
    final cachedBytes = pictureProvider.getCachedPictureBytes(pictureId);
    if (cachedBytes != null) {
      return SizedBox.expand(
        child: Image.memory(cachedBytes, fit: BoxFit.cover),
      );
    }

    return FutureBuilder<Uint8List>(
      future: pictureProvider.getPictureBytes(pictureId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.pink),
          );
        }
        final bytes = snapshot.data;
        if (bytes != null) {
          return SizedBox.expand(child: Image.memory(bytes, fit: BoxFit.cover));
        }
        return placeholder;
      },
    );
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
                  child: _buildImage(context),
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
