import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:pocketeer_mobile/data/models/item_types/item_type.dart';
import 'package:pocketeer_mobile/providers/picture_provider.dart';
import 'package:provider/provider.dart';
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
        leading: _buildImage(context),
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

  Widget _buildImage(BuildContext context) {
    final placeholder = const Icon(
      Icons.image,
      color: AppColors.purple,
      size: 40,
    );

    final pictureHash =
        itemType.pictureHash; // <--- ВИКОРИСТОВУЄМО HASH З itemType

    if (pictureHash == null) {
      return _imageContainer(icon: placeholder); // Немає зображення
    }

    final provider = context.read<PictureProvider>();

    // 1. ПЕРЕВІРКА КЕШУ: ВИКОРИСТОВУЄМО getCachedPictureBytesByHash
    final cachedBytes = provider.getCachedPictureBytesByHash(pictureHash);
    if (cachedBytes != null) {
      return _imageContainer(image: MemoryImage(cachedBytes)); // З кешу
    }

    // 2. ЗАВАНТАЖЕННЯ: ВИКОРИСТОВУЄМО getPictureBytesByHash
    return FutureBuilder<Uint8List>(
      future: provider.getPictureBytesByHash(pictureHash),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _imageContainer(loading: true); // Завантаження
        }
        final bytes = snapshot.data;
        if (bytes != null) {
          return _imageContainer(
            image: MemoryImage(bytes),
          ); // Успішно завантажено
        }
        return _imageContainer(icon: placeholder); // Помилка/Відсутність даних
      },
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
