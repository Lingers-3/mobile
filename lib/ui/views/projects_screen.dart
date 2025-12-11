import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pocketeer_mobile/data/models/resource_reservations/resource_reservation.dart';
import 'package:pocketeer_mobile/providers/item_provider.dart';
import 'package:pocketeer_mobile/providers/resource_reservation_provider.dart';
import 'package:pocketeer_mobile/ui/widgets/resource_reservation/resource_reservation_card.dart';
import 'package:pocketeer_mobile/ui/widgets/custom_text_field.dart';

class ProjectsScreen extends StatefulWidget {
  const ProjectsScreen({super.key});

  @override
  State<ProjectsScreen> createState() => _ProjectsScreenState();
}

class _ProjectsScreenState extends State<ProjectsScreen> {
  @override
  void initState() {
    super.initState();
    // Виконуємо завантаження даних після побудови віджета
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  Future<void> _loadData() async {
    // Завантажуємо резервації
    await context.read<ResourceReservationProvider>().loadReservations();
    // Також переконуємося, що завантажені предмети (щоб мати назви та фото)
    if (mounted) {
      await context.read<ItemProvider>().loadAllItems();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Резервації (Тест)'),
        centerTitle: true,
      ),
      body: Consumer<ResourceReservationProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.error != null) {
            return Center(
              child: Text(
                'Помилка: ${provider.error}',
                style: const TextStyle(color: Colors.red),
              ),
            );
          }

          if (provider.reservations.isEmpty) {
            return const Center(
              child: Text(
                'Немає активних резервацій.\nНатисніть "+", щоб додати тестову.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(8),
            itemCount: provider.reservations.length,
            itemBuilder: (context, index) {
              final reservation = provider.reservations[index];
              return ResourceReservationCard(reservation: reservation);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  // Тимчасовий діалог для тестування створення
  void _showAddDialog(BuildContext context) {
    final quantityController = TextEditingController();
    // Для тесту беремо перший ліпший предмет з інвентаря, або просимо ввести ID
    // Тут зробимо спрощено: вводимо ID предмета та кількість.
    final itemIdController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Додати резервацію'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Для тесту введіть ID існуючого предмета (наприклад 101 або подивіться в консолі при завантаженні предметів)',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 10),
            CustomTextField(
              controller: itemIdController,
              labelText: 'ID Предмета',
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 10),
            CustomTextField(
              controller: quantityController,
              labelText: 'Кількість',
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
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
              final itemId = int.tryParse(itemIdController.text);
              final qty = double.tryParse(quantityController.text);

              if (itemId != null && qty != null) {
                context
                    .read<ResourceReservationProvider>()
                    .addReservation(itemId, qty);
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