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
import 'package:pocketeer_mobile/theme/app_theme.dart';

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

    final itemType = context.select<ItemTypeProvider, ItemType?>(
      (itp) => itp.itemTypes
          .where((it) => it.id == specification.itemTypeId)
          .firstOrNull,
    );

    if (itemType == null) {
      // TODO(saloway): handle gracefuly
      return const Center(child: Text("The item type is null"));
    }

    final typeName = itemType.name;
    final unit = itemType.displayMeasurementUnit;

    final itemsOfThisType = context.select<ItemProvider, List<Item>>(
      (ip) => ip.getItemsByType(specification.itemTypeId),
    );

    final itemsById = {for (var i in itemsOfThisType) i.id: i};

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
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // TYPE NAME
            Expanded(
              child: Text(
                typeName,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.purple,
                ),
              ),
            ),
            // SPECIFICATION RESOURCE TYPE
            Chip(
              label: Text(specification.resourceTypeLabel),
              backgroundColor: AppColors.dialogBackground,
              labelStyle: const TextStyle(color: AppColors.pink),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // --- HEADER: Інформація про специфікацію ---
          Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                // SPECIFICATION STATS
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _statColumn(
                      'Planned',
                      specification.plannedQuantity,
                      unit,
                      Colors.grey,
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
            child: CustomScrollView(
              slivers: [
                // --- RESERVED RESOURCES HEADER ---
                SliverToBoxAdapter(
                  child: _sectionHeader(
                    'Reserved resources',
                    reservations.length,
                  ),
                ),

                // --- RESERVED RESOURCES LIST ---
                if (reservations.isEmpty)
                  const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Text(
                        'There is nothing to add',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                  )
                else
                  SliverList.builder(
                    itemCount: reservations.length,
                    itemBuilder: (context, index) {
                      final r = reservations[index];
                      final item = itemsById[r.itemId];
                      if (item == null) {
                        throw Exception('Item is null');
                      }
                      return ResourceReservationCard(
                        key: ValueKey(r.id),
                        projectId: project.id,
                        specificationId: specification.id,
                        itemType: itemType,
                        item: item,
                        reservation: r,
                      );
                    },
                  ),

                // --- SPACER ---
                const SliverToBoxAdapter(child: SizedBox(height: 16)),

                // --- INVENTORY HEADER ---
                SliverToBoxAdapter(
                  child: _sectionHeader(
                    'Available in the inventory',
                    availableInventory.length,
                  ),
                ),

                // --- INVENTORY LIST ---
                if (availableInventory.isEmpty)
                  const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Text(
                        'No free items of this type',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                  )
                else
                  SliverList.builder(
                    itemCount: availableInventory.length,
                    itemBuilder: (context, index) {
                      final item = availableInventory[index];
                      return ProjectInventoryTile(
                        key: ValueKey(item.id),
                        itemType: itemType,
                        item: item,
                        onAdd: () => _showAddReservationDialog(
                          context,
                          specification,
                          itemType,
                          item,
                        ),
                        onTap: () => _showItemDetails(context, item),
                      );
                    },
                  ),

                // --- BOTTOM PADDING ---
                const SliverToBoxAdapter(child: SizedBox(height: 40)),
              ],
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
        Text(
          label,
          style: const TextStyle(color: AppColors.purple, fontSize: 12),
        ),
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
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title.toUpperCase(),
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: AppColors.purple,
              fontSize: 13,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: AppColors.dialogBackground,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              '$count',
              style: const TextStyle(
                fontSize: 11,
                color: AppColors.purple,
                fontWeight: FontWeight.bold,
              ),
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
            onPressed: () async {
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

              final navigator = Navigator.of(ctx);

              context.read<ProjectProvider>().reserveItem(
                widget.projectId,
                specification.id,
                item.id,
                reservedQuantity,
                usedQuantity ?? 0,
              );
              if (navigator.mounted) {
                navigator.pop();
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }
}
