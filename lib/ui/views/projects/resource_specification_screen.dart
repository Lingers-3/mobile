import 'package:flutter/material.dart';
import 'package:pocketeer_mobile/data/models/item_types/item_type.dart';
import 'package:pocketeer_mobile/data/models/projects/project.dart';
import 'package:pocketeer_mobile/data/models/projects/project_state.dart';
import 'package:pocketeer_mobile/providers/resource_specification_provider.dart';
import 'package:provider/provider.dart';
import 'package:pocketeer_mobile/data/models/items/item.dart';
import 'package:pocketeer_mobile/data/models/resource_specifications/resource_specification.dart';
import 'package:pocketeer_mobile/providers/item_provider.dart';
import 'package:pocketeer_mobile/providers/resource_reservation_provider.dart';
import 'package:pocketeer_mobile/ui/widgets/custom_text_field.dart';
import 'package:pocketeer_mobile/ui/widgets/resource_reservation/project_inventory_tile.dart';
import 'package:pocketeer_mobile/ui/widgets/resource_reservation/resource_reservation_card.dart';
import 'package:pocketeer_mobile/ui/widgets/resource_reservation/item_details_dialog.dart';

class ResourceSpecificationScreen extends StatefulWidget {
  final ResourceSpecification specification;
  final ProjectState projectStatus;
  final ItemType itemType;

  const ResourceSpecificationScreen({
    super.key,
    required this.specification,
    required this.projectStatus,
    required this.itemType,
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
      context.read<ResourceReservationProvider>().loadReservations();
      context.read<ItemProvider>().loadAllItems();
    });
  }

  @override
  Widget build(BuildContext context) {
    final resourceSpecification = context
        .watch<ResourceSpecificationProvider>()
        .specifications
        .firstWhere(
          (rs) => rs.id == widget.specification.id,
          orElse: () => widget.specification,
        );

    final typeName = widget.itemType.name;
    final unit = widget.itemType.displayMeasurementUnit;

    // 2. Отримуємо дані з провайдерів
    final reservationProvider = context.watch<ResourceReservationProvider>();
    final itemProvider = context.watch<ItemProvider>();

    // 3. ФІЛЬТРАЦІЯ: Нам потрібні тільки дані, що стосуються itemTypeId цієї специфікації

    final itemsOfThisType = itemProvider.getItemsByType(
      resourceSpecification.itemTypeId,
    );
    final itemsIdsOfThisType = itemsOfThisType.map((i) => i.id).toSet();

    // Всі резервації, які посилаються на предмети цього типу
    final relevantReservations = reservationProvider.reservations
        .where(
          (r) =>
              itemsIdsOfThisType.contains(r.itemId) &&
              r.resourceSpecificationId == resourceSpecification.id,
        )
        .toList();

    // ID предметів, які вже зарезервовані (в межах специфікації цього проекту)
    // Увага: тут спрощення. В реальності треба перевіряти, чи зарезервований предмет саме під цю специфікацію.
    // Поки що вважаємо, що всі резервації цього типу належать сюди (для демо).
    final reservedItemIds = relevantReservations.map((r) => r.itemId).toSet();

    // Доступний інвентар: предмети цього типу, яких немає в резерваціях
    final availableInventory = itemsOfThisType
        .where((i) => !reservedItemIds.contains(i.id))
        .toList();

    // 4. ПІДРАХУНОК СТАТИСТИКИ
    // NOTE(saloway): очікується від бекенду через провайдер специфікацій
    final totalReserved = relevantReservations.fold(
      0.0,
      (sum, r) => sum + r.reservedQuantity,
    );
    final totalUsed = relevantReservations.fold(
      0.0,
      (sum, r) => sum + r.usedQuantity,
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Специфікація ресурсу')),
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
                      label: Text(resourceSpecification.resourceTypeLabel),
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
                      'Заплановано',
                      resourceSpecification.plannedQuantity,
                      unit,
                      Colors.black,
                      true,
                    ),
                    _statColumn(
                      'Зарезервовано',
                      totalReserved,
                      unit,
                      Colors.blue,
                      widget.projectStatus != ProjectState.planned,
                    ),
                    _statColumn(
                      'Витрачено',
                      totalUsed,
                      unit,
                      totalUsed > resourceSpecification.plannedQuantity
                          ? Colors.red
                          : Colors.green,
                      widget.projectStatus != ProjectState.planned,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                // Прогрес бар
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: resourceSpecification.plannedQuantity > 0
                        ? (totalReserved /
                                  resourceSpecification.plannedQuantity)
                              .clamp(0.0, 1.0)
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
                  _sectionHeader(
                    'Зарезервовані ресурси',
                    relevantReservations.length,
                  ),
                  if (relevantReservations.isEmpty)
                    const Padding(
                      padding: EdgeInsets.all(16),
                      child: Text(
                        'Поки що нічого не зарезервовано',
                        style: TextStyle(color: Colors.grey),
                      ),
                    )
                  else
                    ...relevantReservations.map(
                      (r) => ResourceReservationCard(reservation: r),
                    ),

                  const SizedBox(height: 16),

                  // Секція Інвентарю
                  _sectionHeader(
                    'Доступно в інвентарі',
                    availableInventory.length,
                  ),
                  if (availableInventory.isEmpty)
                    const Padding(
                      padding: EdgeInsets.all(16),
                      child: Text(
                        'Немає вільних предметів цього типу',
                        style: TextStyle(color: Colors.grey),
                      ),
                    )
                  else
                    ...availableInventory.map(
                      (item) => ProjectInventoryTile(
                        item: item,
                        onAdd: () => _showAddReservationDialog(
                          context,
                          resourceSpecification,
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
    ResourceSpecification resourceSpecification,
    Item item,
  ) {
    final quantityController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Зарезервувати'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Скільки взяти з "${widget.itemType.name}"?'),
            CustomTextField(
              controller: quantityController,
              labelText: 'Кількість',
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Скасувати'),
          ),
          TextButton(
            onPressed: () {
              final qty = double.tryParse(quantityController.text);

              if (qty == null || qty <= 0) {
                ScaffoldMessenger.of(ctx).showSnackBar(
                  const SnackBar(content: Text('Введіть число більше нуля')),
                );
                return;
              }

              context.read<ResourceReservationProvider>().addReservation(
                resourceSpecification.id,
                item.id,
                qty,
              );
              Navigator.pop(ctx);
            },
            child: const Text('Додати'),
          ),
        ],
      ),
    );
  }
}
