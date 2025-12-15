import 'package:flutter/material.dart';
import 'package:pocketeer_mobile/data/models/item_types/item_type.dart';
import 'package:pocketeer_mobile/data/models/projects/project.dart';
import 'package:pocketeer_mobile/data/models/projects/project_state.dart';
import 'package:pocketeer_mobile/providers/item_type_provider.dart';
import 'package:pocketeer_mobile/providers/project_provider.dart';
import 'package:provider/provider.dart';
import 'package:pocketeer_mobile/data/models/items/item.dart';
import 'package:pocketeer_mobile/data/models/resource_specifications/resource_specification.dart';
import 'package:pocketeer_mobile/providers/item_provider.dart';
import 'package:pocketeer_mobile/ui/widgets/custom_text_field.dart';
import 'package:pocketeer_mobile/ui/widgets/resource_reservation/project_inventory_tile.dart';
import 'package:pocketeer_mobile/ui/widgets/resource_reservation/resource_reservation_card.dart';
import 'package:pocketeer_mobile/ui/widgets/resource_reservation/item_details_dialog.dart';

class ResourceSpecificationScreen extends StatefulWidget {
  final int projectId;
  final int specificationId;

  const ResourceSpecificationScreen({
    super.key,
    required this.projectId,
    required this.specificationId,
  });

  @override
  State<ResourceSpecificationScreen> createState() =>
      _ResourceSpecificationScreenState();
}

class _ResourceSpecificationScreenState
    extends State<ResourceSpecificationScreen> {
  @override
  void initState() {
    super.initState();
    // Update data
    context.read<ProjectProvider>().fetchProject(widget.projectId);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ItemProvider>().loadAllItems();
    });
  }

  @override
  Widget build(BuildContext context) {
    final project = context.select<ProjectProvider, Project?>(
      (pp) => pp.getById(widget.projectId),
    );

    if (project == null) {
      // TODO(saloway): handle gracefuly
      return const Center(child: Text("The project is null"));
    }

    final specification = project.specifications?.firstWhere(
      (s) => s.id == widget.specificationId,
    );

    if (specification == null) {
      // TODO(saloway): handle gracefuly
      return const Center(child: Text("The specification is null"));
    }

    final reservations = specification.reservations ?? [];

    final specificationItemType = context.select<ItemTypeProvider, ItemType>(
      (itp) =>
          itp.itemTypes.firstWhere((it) => it.id == specification.itemTypeId),
    );

    final typeName = specificationItemType.name;
    final unit = specificationItemType.displayMeasurementUnit;

    final itemsOfThisType = context.read<ItemProvider>().getItemsByType(
      specification.itemTypeId,
    );

    final reservedItemIds = reservations.map((r) => r.itemId).toSet();

    // Доступний інвентар: предмети цього типу, яких немає в резерваціях
    final availableInventory = itemsOfThisType
        .where((i) => !reservedItemIds.contains(i.id))
        .toList();

    // 4. ПІДРАХУНОК СТАТИСТИКИ
    final totalReserved = reservations.fold(
      0.0,
      (sum, r) => sum + r.reservedQuantity,
    );
    final totalUsed = reservations.fold(0.0, (sum, r) => sum + r.usedQuantity);

    return Scaffold(
      appBar: AppBar(title: const Text('Resource specification')),
      body: Column(
        children: [
          // --- HEADER: Інформація про специфікацію ---
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // TYPE NAME
                    Expanded(
                      child: Text(
                        typeName,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    // SPECIFICATION RESOURCE TYPE
                    Chip(
                      label: Text(specification.resourceTypeLabel),
                      backgroundColor: Colors.blue.shade50,
                      labelStyle: const TextStyle(color: Colors.blue),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // SPECIFICATION STATS
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _statColumn(
                      'Planned',
                      specification.plannedQuantity,
                      unit,
                      Colors.black,
                      true,
                    ),
                    _statColumn(
                      'Reserved',
                      totalReserved,
                      unit,
                      Colors.blue,
                      project.state != ProjectState.planned,
                    ),
                    _statColumn(
                      'Used',
                      totalUsed,
                      unit,
                      totalUsed > specification.plannedQuantity
                          ? Colors.red
                          : Colors.green,
                      project.state != ProjectState.planned,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                // Прогрес бар
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: specification.plannedQuantity > 0
                        ? (totalReserved / specification.plannedQuantity).clamp(
                            0.0,
                            1.0,
                          )
                        : 0,
                    backgroundColor: Colors.grey.shade200,
                    color: Colors.blue,
                    minHeight: 8,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          // --- LISTS ---
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // Секція Резервацій
                  _sectionHeader('Reserved resources', reservations.length),
                  if (reservations.isEmpty)
                    const Padding(
                      padding: EdgeInsets.all(16),
                      child: Text(
                        'There is nothing to add',
                        style: TextStyle(color: Colors.grey),
                      ),
                    )
                  else
                    ...reservations.map(
                      (r) => ResourceReservationCard(reservation: r),
                    ),

                  const SizedBox(height: 16),

                  // Секція Інвентарю
                  _sectionHeader(
                    'Available in the inventory',
                    availableInventory.length,
                  ),
                  if (availableInventory.isEmpty)
                    const Padding(
                      padding: EdgeInsets.all(16),
                      child: Text(
                        'No free items of this type',
                        style: TextStyle(color: Colors.grey),
                      ),
                    )
                  else
                    ...availableInventory.map(
                      (item) => ProjectInventoryTile(
                        item: item,
                        onAdd: () => _showAddReservationDialog(
                          context,
                          specification,
                          specificationItemType,
                          item,
                        ),
                        onTap: () => _showItemDetails(context, item),
                      ),
                    ),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _statColumn(
    String label,
    double value,
    String unit,
    Color color,
    bool active,
  ) {
    return Column(
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
        const SizedBox(height: 4),
        Text(
          active ? '${value.toStringAsFixed(1)} $unit' : '—',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _sectionHeader(String title, int count) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      color: Colors.grey.shade50,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title.toUpperCase(),
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.grey,
              fontSize: 13,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              '$count',
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  void _showItemDetails(BuildContext context, Item item) {
    showDialog(
      context: context,
      builder: (_) => ItemDetailsDialog(item: item),
    );
  }

  void _showAddReservationDialog(
    BuildContext context,
    ResourceSpecification specification,
    ItemType itemType,
    Item item,
  ) {
    final reservedQuantityController = TextEditingController();
    final usedQuantityController = TextEditingController();
    final itemTypeName = itemType.name;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Reserve $itemTypeName'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // TODO(saloway): fix labels
            Text('Reserve'),
            CustomTextField(
              controller: reservedQuantityController,
              labelText: 'Quantity (${itemType.baseMeasurementUnit})',
              keyboardType: TextInputType.number,
            ),
            Text('Use'),
            CustomTextField(
              controller: usedQuantityController,
              labelText: 'Quantity (${itemType.baseMeasurementUnit})',
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final reservedQuantity = double.tryParse(
                reservedQuantityController.text,
              );
              final usedQuantity = double.tryParse(usedQuantityController.text);

              if (reservedQuantity == null ||
                  reservedQuantity <= 0 ||
                  (usedQuantity != null && usedQuantity <= 0)) {
                ScaffoldMessenger.of(ctx).showSnackBar(
                  const SnackBar(content: Text('Enter value greater than 0')),
                );
                return;
              }
              if (usedQuantity != null && usedQuantity > reservedQuantity) {
                ScaffoldMessenger.of(ctx).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Used quantity shall not be greater than reserved',
                    ),
                  ),
                );
                return;
              }
              context.read<ProjectProvider>().reserveItem(
                widget.projectId,
                specification.id,
                item.id,
                reservedQuantity,
                usedQuantity ?? 0,
              );
              Navigator.pop(ctx);
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }
}
