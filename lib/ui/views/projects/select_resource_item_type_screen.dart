import 'package:flutter/material.dart';
import 'package:pocketeer_mobile/theme/app_theme.dart';
import 'package:provider/provider.dart';
import 'package:pocketeer_mobile/providers/item_provider.dart';
import 'package:pocketeer_mobile/providers/item_type_provider.dart';
import 'package:pocketeer_mobile/ui/widgets/item_type_card.dart';
import 'package:pocketeer_mobile/ui/widgets/resource_specification/add_specification_dialog.dart';

class SelectResourceItemTypeScreen extends StatelessWidget {
  // Додаємо параметр для фільтрації
  final List<int> excludedItemTypeIds;
  final int projectId;

  const SelectResourceItemTypeScreen({
    super.key,
    this.excludedItemTypeIds = const [],
    required this.projectId,
  });

  @override
  Widget build(BuildContext context) {
    final typeProvider = context.watch<ItemTypeProvider>();
    final itemProvider = context.watch<ItemProvider>();

    // Фільтруємо типи: беремо тільки ті, чиїх ID немає в списку виключень
    final itemTypes = typeProvider.itemTypes
        .where((type) => !excludedItemTypeIds.contains(type.id))
        .toList();

    return Scaffold(
      backgroundColor: AppColors.primaryBackground,
      appBar: AppBar(
        backgroundColor: AppColors.primaryBackground,
        title: const Text(
          'Choose resource type',
          style: TextStyle(color: AppColors.purple),
        ),
        iconTheme: IconThemeData(color: AppColors.purple),
      ),
      body: itemTypes.isEmpty
          ? const Center(
              child: Text(
                'All avalaible types were added to the project\nor inventory is empty.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.purple),
              ),
            )
          : GridView.builder(
              padding: const EdgeInsets.all(12),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 0.8,
              ),
              itemCount: itemTypes.length,
              itemBuilder: (context, index) {
                final type = itemTypes[index];
                final totalQty = itemProvider.getTotalQuantity(
                  type.id,
                  type.baseMeasurementUnit,
                  type.displayMeasurementUnit,
                );

                return ItemTypeCard(
                  itemType: type,
                  isSelected: false,
                  imageUrl: null,
                  pictureId: type.pictureId,
                  expirationStatus: itemProvider.getTypeExpirationStatus(
                    type.id,
                  ),
                  totalQuantity: totalQty,
                  onTap: () async {
                    final result = await showDialog(
                      context: context,
                      builder: (_) => AddSpecificationDialog(
                        itemType: type,
                        projectId: projectId,
                      ),
                    );

                    if (result == true && context.mounted) {
                      Navigator.pop(context);
                    }
                  },
                  // Вимикаємо зайві кнопки для режиму вибору
                  onDelete: null,
                  onOpen: null,
                  onLongPress: null,
                );
              },
            ),
    );
  }
}
