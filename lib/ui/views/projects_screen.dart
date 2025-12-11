import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pocketeer_mobile/data/models/items/item.dart';
import 'package:pocketeer_mobile/data/models/resource_reservations/resource_reservation.dart';
import 'package:pocketeer_mobile/providers/item_provider.dart';
import 'package:pocketeer_mobile/providers/item_type_provider.dart';
import 'package:pocketeer_mobile/providers/resource_reservation_provider.dart';
import 'package:pocketeer_mobile/ui/widgets/custom_text_field.dart';
import 'package:pocketeer_mobile/ui/widgets/resource_reservation/project_inventory_tile.dart';
import 'package:pocketeer_mobile/ui/widgets/resource_reservation/resource_reservation_card.dart';

class ProjectsScreen extends StatefulWidget {
  const ProjectsScreen({super.key});

  @override
  State<ProjectsScreen> createState() => _ProjectsScreenState();
}

class _ProjectsScreenState extends State<ProjectsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  Future<void> _loadData() async {
    // Завантажуємо всі необхідні дані
    await Future.wait([
      context.read<ResourceReservationProvider>().loadReservations(),
      context.read<ItemProvider>().loadAllItems(),
      context.read<ItemTypeProvider>().loadItemTypes(),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    // Отримуємо дані з провайдерів
    final reservationProvider = context.watch<ResourceReservationProvider>();
    final itemProvider = context.watch<ItemProvider>();

    final reservations = reservationProvider.reservations;
    final allItems = itemProvider.items;

    // --- ЛОГІКА ФІЛЬТРАЦІЇ ---
    // 1. Отримуємо ID всіх зарезервованих предметів
    final reservedItemIds = reservations.map((r) => r.itemId).toSet();

    // 2. Фільтруємо інвентар: показуємо тільки ті, що НЕ зарезервовані
    final availableItems = allItems
        .where((i) => !reservedItemIds.contains(i.id))
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Управління ресурсами'),
        centerTitle: true,
      ),
      body: reservationProvider.isLoading || itemProvider.loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // --- СЕКЦІЯ 1: ЗАРЕЗЕРВОВАНІ РЕСУРСИ ---
                _buildSectionHeader('Зарезервовано', reservations.length),
                Expanded(
                  flex: 4, // 40% екрану (приблизно)
                  child: reservations.isEmpty
                      ? _buildEmptyState('Немає зарезервованих ресурсів')
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          itemCount: reservations.length,
                          itemBuilder: (context, index) {
                            return ResourceReservationCard(
                              reservation: reservations[index],
                            );
                          },
                        ),
                ),

                const Divider(height: 1, thickness: 1),

                // --- СЕКЦІЯ 2: ДОСТУПНИЙ ІНВЕНТАР ---
                _buildSectionHeader('Інвентар', availableItems.length),
                Expanded(
                  flex: 6, // 60% екрану
                  child: availableItems.isEmpty
                      ? _buildEmptyState(
                          'Інвентар порожній або все зарезервовано',
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          itemCount: availableItems.length,
                          itemBuilder: (context, index) {
                            final item = availableItems[index];
                            return ProjectInventoryTile(
                              item: item,
                              onAdd: () =>
                                  _showAddReservationDialog(context, item),
                              onTap: () => _showItemDetails(context, item),
                            );
                          },
                        ),
                ),
              ],
            ),
    );
  }

  Widget _buildSectionHeader(String title, int count) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      color: Colors.grey.shade100,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title.toUpperCase(),
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.grey,
              letterSpacing: 1.1,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '$count',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text(
          message,
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.grey),
        ),
      ),
    );
  }

  // Діалог додавання (Резервації)
  void _showAddReservationDialog(BuildContext context, Item item) {
    final quantityController = TextEditingController();
    String? errorText;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text('Зарезервувати предмет'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Предмет: ${item.description ?? "Без назви"}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  'Доступно на складі: ${item.quantity} ${item.displayMeasurementUnit}',
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: quantityController,
                  labelText: 'Необхідна кількість',
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                ),
                if (errorText != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      errorText!,
                      style: const TextStyle(color: Colors.red, fontSize: 12),
                    ),
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
                    setState(() => errorText = 'Введіть коректну кількість');
                    return;
                  }

                  // Тут можна додати валідацію, чи не перевищує резерв загальну кількість
                  // if (qty > item.quantity) ...

                  context
                      .read<ResourceReservationProvider>()
                      .addReservation(item.id, qty)
                      .then((_) => Navigator.pop(ctx));
                },
                child: const Text('Зарезервувати'),
              ),
            ],
          );
        },
      ),
    );
  }

  // Діалог перегляду деталей (Read-only)
  void _showItemDetails(BuildContext context, Item item) {
    // Отримуємо назву типу для заголовка
    final typeName = context
        .read<ItemTypeProvider>()
        .itemTypes
        .firstWhere(
          (t) => t.id == item.itemTypeId,
          orElse: () =>
              // Якщо не знайдено (що малоймовірно), створюємо пустий об'єкт або кидаємо error
              // Для безпеки просто повернемо тип з пустим ім'ям, щоб не крашити
              throw Exception("Type not found"), // або обробити м'якше
        )
        .name;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(item.description ?? typeName),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _detailRow('Тип:', typeName),
            _detailRow(
              'Кількість:',
              '${item.quantity} ${item.displayMeasurementUnit}',
            ),
            if (item.purchasePrice != null)
              _detailRow('Ціна:', '${item.purchasePrice}'),
            _detailRow('Створено:', item.createdAt.toString().split(' ')[0]),
            if (item.expirationDate != null)
              _detailRow(
                'Термін придатності:',
                item.expirationDate.toString().split(' ')[0],
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Закрити'),
          ),
        ],
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
