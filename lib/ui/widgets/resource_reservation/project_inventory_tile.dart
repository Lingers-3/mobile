import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pocketeer_mobile/data/models/items/item.dart';
import 'package:pocketeer_mobile/providers/item_type_provider.dart';

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
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.1)
          ),
          child: const Icon(Icons.inventory_2, color: Colors.blue, size: 24),
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
