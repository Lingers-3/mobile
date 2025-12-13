import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pocketeer_mobile/data/models/items/item.dart';
import 'package:pocketeer_mobile/providers/tag_provider.dart';
import 'package:pocketeer_mobile/theme/app_theme.dart';

class ItemDetailsDialog extends StatefulWidget {
  final Item item;

  const ItemDetailsDialog({super.key, required this.item});

  @override
  State<ItemDetailsDialog> createState() => _ItemDetailsDialogState();
}

class _ItemDetailsDialogState extends State<ItemDetailsDialog> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final prov = context.read<TagProvider>();
      if (prov.tags.isEmpty && !prov.loading) {
        prov.loadTags();
      }
    });
  }

  Widget infoTile(String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(color: AppColors.purple, fontSize: 12),
          ),
          const SizedBox(height: 4),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.dialogBackground,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: AppColors.purple.withValues(alpha: 0.3),
              ),
            ),
            child: Text(
              value,
              style: const TextStyle(color: AppColors.pink, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    final tagProv = context.watch<TagProvider>();
    final tagNames = tagProv
        .tagsForItem(item.tagIds)
        .map((t) => t.name)
        .toList();

    return AlertDialog(
      backgroundColor: AppColors.primaryBackground,
      title: const Text(
        "Деталі предмету",
        style: TextStyle(color: AppColors.purple),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            infoTile("Опис", item.description ?? "-"),
            infoTile("Кількість", item.quantity.toString()),
            infoTile("Одиниця виміру", item.displayMeasurementUnit),
            infoTile(
              "Термін придатності",
              item.expirationDate != null
                  ? (() {
                      final d = item.expirationDate!.toLocal();
                      return "${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}";
                    })()
                  : "-",
            ),
            infoTile(
              "Ціна покупки",
              item.purchasePrice?.toStringAsFixed(2) ?? "-",
            ),
            infoTile("Теги", tagNames.isEmpty ? "-" : tagNames.join(", ")),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Закрити", style: TextStyle(color: AppColors.pink)),
        ),
      ],
    );
  }
}
