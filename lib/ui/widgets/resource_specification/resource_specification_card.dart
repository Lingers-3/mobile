import 'package:flutter/material.dart';
import 'package:pocketeer_mobile/data/models/resource_specifications/resource_type.dart';
import 'package:provider/provider.dart';
import 'package:pocketeer_mobile/data/models/resource_specifications/resource_specification.dart';
import 'package:pocketeer_mobile/data/models/item_types/item_type.dart';
import 'package:pocketeer_mobile/providers/item_provider.dart';
import 'package:pocketeer_mobile/providers/resource_reservation_provider.dart';

class ResourceSpecificationCard extends StatelessWidget {
  final ResourceSpecification specification;
  final VoidCallback? onTap;
  final ItemType itemType;

  const ResourceSpecificationCard({
    super.key,
    required this.specification,
    required this.itemType,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final String unit = itemType.displayMeasurementUnit;
    final String name = itemType.name;

    // 2. ПІДРАХУНОК ФАКТИЧНИХ ДАНИХ
    // Нам потрібно знайти всі резервації, які стосуються цього типу предметів
    // і підсумувати їх.

    // Крок А: Знаходимо ID всіх предметів цього типу
    final allItems = context
        .read<ItemProvider>()
        .items; // read тут ок, бо ми слухаємо зміни нижче або вище по дереву
    final itemIdsOfType = allItems
        .where((i) => i.itemTypeId == specification.itemTypeId)
        .map((i) => i.id)
        .toSet();

    // Крок Б: Слухаємо провайдер резервацій і фільтруємо
    final reservationProvider = context.watch<ResourceReservationProvider>();
    final relevantReservations = reservationProvider.reservations.where(
      (r) => itemIdsOfType.contains(r.itemId),
    );

    // Крок В: Сумуємо
    final double actualReserved = relevantReservations.fold(
      0,
      (sum, r) => sum + r.reservedQuantity,
    );
    final double actualUsed = relevantReservations.fold(
      0,
      (sum, r) => sum + r.usedQuantity,
    );

    // Візуальні налаштування
    final isTool = specification.resourceType == ResourceType.tool;
    final typeColor = isTool ? Colors.orange : Colors.blue;
    final typeIcon = isTool ? Icons.handyman : Icons.layers;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            children: [
              // --- Верхній рядок: Картинка + Назва + Тип ---
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Placeholder для картинки (або реальне фото, якщо є URL)
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(8),
                      image: itemType.pictureId != null
                          ? null // Тут можна додати NetworkImage, якщо реалізувати завантаження фото
                          : null,
                    ),
                    child: itemType.pictureId == null
                        ? Icon(typeIcon, color: typeColor, size: 28)
                        : null,
                  ),
                  const SizedBox(width: 12),

                  // Назва та бейдж типу
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: typeColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(
                              color: typeColor.withValues(alpha: 0.3),
                            ),
                          ),
                          child: Text(
                            specification.resourceTypeLabel,
                            style: TextStyle(
                              color: typeColor,
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8.0),
                child: Divider(height: 1),
              ),

              // --- Нижній рядок: Статистика ---
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildStatItem(
                    'План',
                    specification.plannedQuantity,
                    unit,
                    Colors.black87,
                  ),
                  _buildVerticalDivider(),
                  _buildStatItem(
                    'Резерв',
                    actualReserved,
                    unit,
                    Colors.blue.shade700,
                  ),
                  _buildVerticalDivider(),
                  _buildStatItem(
                    'Витрачено',
                    actualUsed,
                    unit,
                    actualUsed > specification.plannedQuantity
                        ? Colors.red
                        : Colors.green.shade700,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, double value, String unit, Color color) {
    return Expanded(
      child: Column(
        children: [
          Text(
            label.toUpperCase(),
            style: TextStyle(
              fontSize: 10,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 2),
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: value
                      .toStringAsFixed(1)
                      .replaceAll(RegExp(r'\.0$'), ''), // 5.0 -> 5
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    fontFamily: 'Roboto', // Або ваш шрифт
                  ),
                ),
                TextSpan(
                  text: ' $unit',
                  style: TextStyle(
                    color: color.withValues(alpha: 0.7),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVerticalDivider() {
    return Container(height: 24, width: 1, color: Colors.grey.shade300);
  }
}
