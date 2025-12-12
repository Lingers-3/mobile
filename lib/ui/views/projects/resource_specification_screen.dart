import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pocketeer_mobile/data/models/items/item.dart';
import 'package:pocketeer_mobile/data/models/resource_specifications/resource_specification.dart';
import 'package:pocketeer_mobile/providers/item_provider.dart';
import 'package:pocketeer_mobile/providers/item_type_provider.dart';
import 'package:pocketeer_mobile/providers/resource_reservation_provider.dart';
import 'package:pocketeer_mobile/ui/widgets/custom_text_field.dart';
import 'package:pocketeer_mobile/ui/widgets/resource_reservation/project_inventory_tile.dart';
import 'package:pocketeer_mobile/ui/widgets/resource_reservation/resource_reservation_card.dart';

class ResourceSpecificationScreen extends StatefulWidget {
  final ResourceSpecification specification;

  const ResourceSpecificationScreen({super.key, required this.specification});

  @override
  State<ResourceSpecificationScreen> createState() =>
      _ResourceSpecificationScreenState();
}

class _ResourceSpecificationScreenState
    extends State<ResourceSpecificationScreen> {
  @override
  void initState() {
    super.initState();
    // Оновлюємо дані при вході
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ResourceReservationProvider>().loadReservations();
      context.read<ItemProvider>().loadAllItems();
    });
  }

  @override
  Widget build(BuildContext context) {
    final spec = widget.specification;

    // 1. Отримуємо назву типу предмету та одиницю виміру
    final itemType = context.select<ItemTypeProvider, dynamic>((p) {
      try {
        return p.itemTypes.firstWhere((t) => t.id == spec.itemTypeId);
      } catch (e) {
        return null;
      }
    });

    final typeName = itemType?.name ?? 'Невідомий тип';
    final unit = itemType?.displayMeasurementUnit ?? '';

    // 2. Отримуємо дані з провайдерів
    final reservationProvider = context.watch<ResourceReservationProvider>();
    final itemProvider = context.watch<ItemProvider>();

    // 3. ФІЛЬТРАЦІЯ: Нам потрібні тільки дані, що стосуються itemTypeId цієї специфікації

    // Всі предмети цього типу
    final itemsOfThisType = itemProvider.getItemsByType(spec.itemTypeId);
    final itemsIdsOfThisType = itemsOfThisType.map((i) => i.id).toSet();

    // Всі резервації, які посилаються на предмети цього типу
    final relevantReservations = reservationProvider.reservations
        .where((r) => itemsIdsOfThisType.contains(r.itemId))
        .toList();

    // ID предметів, які вже зарезервовані (в межах цього проекту/специфікації)
    // Увага: тут спрощення. В реальності треба перевіряти, чи зарезервований предмет саме під цю специфікацію.
    // Поки що вважаємо, що всі резервації цього типу належать сюди (для демо).
    final reservedItemIds = relevantReservations.map((r) => r.itemId).toSet();

    // Доступний інвентар: предмети цього типу, яких немає в резерваціях
    final availableInventory = itemsOfThisType
        .where((i) => !reservedItemIds.contains(i.id))
        .toList();

    // 4. ПІДРАХУНОК СТАТИСТИКИ
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
                    Expanded(
                      child: Text(
                        typeName,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Chip(
                      label: Text(spec.resourceTypeLabel),
                      backgroundColor: Colors.blue.shade50,
                      labelStyle: const TextStyle(color: Colors.blue),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildStatColumn(
                      'Заплановано',
                      spec.plannedQuantity,
                      unit,
                      Colors.black,
                    ),
                    _buildStatColumn(
                      'Зарезервовано',
                      totalReserved,
                      unit,
                      Colors.blue,
                    ),
                    _buildStatColumn(
                      'Витрачено',
                      totalUsed,
                      unit,
                      totalUsed > spec.plannedQuantity
                          ? Colors.red
                          : Colors.green,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                // Прогрес бар
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: spec.plannedQuantity > 0
                        ? (totalReserved / spec.plannedQuantity).clamp(0.0, 1.0)
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
                  _buildSectionHeader(
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
                  _buildSectionHeader(
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
                        onAdd: () => _showAddReservationDialog(context, item),
                        onTap: () {}, // Тут можна відкрити деталі предмету
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

  Widget _buildStatColumn(
    String label,
    double value,
    String unit,
    Color color,
  ) {
    return Column(
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
        const SizedBox(height: 4),
        Text(
          '${value.toStringAsFixed(1)} $unit',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title, int count) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      color: Colors.grey.shade50,
      child: Row(
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

  void _showAddReservationDialog(BuildContext context, Item item) {
    final quantityController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Зарезервувати'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Скільки взяти з "${item.description}"?'),
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
              if (qty != null) {
                context.read<ResourceReservationProvider>().addReservation(
                  item.id,
                  qty,
                );
                Navigator.pop(ctx);
              }
            },
            child: const Text('Додати'),
          ),
        ],
      ),
    );
  }
}
