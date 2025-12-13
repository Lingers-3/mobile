import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pocketeer_mobile/data/models/items/item.dart';
import 'package:pocketeer_mobile/providers/item_type_provider.dart';
import 'package:pocketeer_mobile/theme/app_theme.dart';

class ProjectInventoryTile extends StatelessWidget {
  final Item item;
  final VoidCallback onAdd;
  final VoidCallback onTap;

  const ProjectInventoryTile({
    super.key,
    required this.item,
    required this.onAdd,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final imageUrl = null;

    final typeName = context.select<ItemTypeProvider, String>((provider) {
      try {
        final type = provider.itemTypes.firstWhere(
          (t) => t.id == item.itemTypeId,
        );
        return type.name;
      } catch (e) {
        return 'Unknown Type';
      }
    });

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: Colors.grey.shade300),
      ),
      child: ListTile(
        onTap: onTap,
        leading: Container(
          height: 64,
          width: 64,
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
              ? const Icon(Icons.image, color: AppColors.purple, size: 40)
              : null,
        ),
        title: Text(
          item.description ?? typeName,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          'Доступно: ${item.quantity} ${item.displayMeasurementUnit}',
          style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
        ),
        trailing: IconButton(
          icon: const Icon(Icons.add_circle_outline, color: Colors.blue),
          onPressed: onAdd,
          tooltip: 'Зарезервувати',
        ),
      ),
    );
  }
}
