import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pocketeer_mobile/data/models/resource_reservations/resource_reservation.dart';
import 'package:pocketeer_mobile/providers/item_provider.dart';
import 'package:pocketeer_mobile/providers/resource_reservation_provider.dart';
import 'package:pocketeer_mobile/ui/widgets/resource_reservation/resource_reservation_edit_dialog.dart';

class ResourceReservationCard extends StatelessWidget {
  final ResourceReservation reservation;

  const ResourceReservationCard({super.key, required this.reservation});

  @override
  Widget build(BuildContext context) {
    final itemProvider = context.watch<ItemProvider>();
    final item = itemProvider.items.cast<dynamic>().firstWhere(
          (i) => i.id == reservation.itemId,
          orElse: () => null,
        );

    if (item == null) {
      return const Card(child: ListTile(title: Text('Завантаження...')));
    }

    final unit = item.displayMeasurementUnit;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Зображення
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.inventory_2_outlined, size: 30),
            ),
            const SizedBox(width: 12),
            
            // Основна інформація
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.description ?? 'Предмет #${item.id}',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  _buildInfoRow('Резерв:', reservation.reservedQuantity, unit, Colors.blue),
                  const SizedBox(height: 4),
                  _buildInfoRow('Використано:', reservation.usedQuantity, unit, Colors.green),
                ],
              ),
            ),

            // Меню дій "..."
            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'edit') {
                  _showEditDialog(context);
                } else if (value == 'delete') {
                  _deleteReservation(context);
                }
              },
              itemBuilder: (BuildContext context) => [
                const PopupMenuItem(
                  value: 'edit',
                  child: Row(
                    children: [Icon(Icons.edit, size: 20), SizedBox(width: 8), Text('Змінити')],
                  ),
                ),
                const PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [Icon(Icons.delete, size: 20, color: Colors.red), SizedBox(width: 8), Text('Видалити', style: TextStyle(color: Colors.red))],
                  ),
                ),
              ],
              icon: const Icon(Icons.more_vert),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, double value, String unit, Color valueColor) {
    return Row(
      children: [
        Text(
          label,
          style: const TextStyle(color: Colors.grey, fontSize: 12),
        ),
        const SizedBox(width: 8),
        Text(
          '${value.toStringAsFixed(2)} $unit',
          style: TextStyle(fontWeight: FontWeight.bold, color: valueColor, fontSize: 14),
        ),
      ],
    );
  }

  void _showEditDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => ResourceReservationEditDialog(
        reservation: reservation,
        onApply: (newReserved, newUsed) {
          context.read<ResourceReservationProvider>().updateReservation(
                reservation.id,
                reservedQuantity: newReserved,
                usedQuantity: newUsed,
              );
        },
      ),
    );
  }

  void _deleteReservation(BuildContext context) {
    // TODO: add delete confirmation dialog
    context.read<ResourceReservationProvider>().deleteReservation(reservation.id);
  }
}