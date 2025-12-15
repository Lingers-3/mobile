import 'package:flutter/material.dart';
import 'package:pocketeer_mobile/data/models/items/item.dart';
import 'package:pocketeer_mobile/providers/item_provider.dart';
import 'package:pocketeer_mobile/providers/item_type_provider.dart';
import 'package:pocketeer_mobile/providers/tag_provider.dart';
import 'package:pocketeer_mobile/theme/app_theme.dart';
import 'package:provider/provider.dart';
import 'edit_item_screen.dart';

class ShowItemScreen extends StatefulWidget {
  final Item item;

  const ShowItemScreen({super.key, required this.item});

  @override
  State<ShowItemScreen> createState() => _ShowItemScreenState();
}

class _ShowItemScreenState extends State<ShowItemScreen> {
  late Item _item;

  @override
  void initState() {
    super.initState();
    _item = widget.item;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final prov = context.read<TagProvider>();
      if (prov.tags.isEmpty && !prov.loading) {
        prov.loadTags();
      }
    });
  }

  Future<void> _openEdit() async {
    final updated = await Navigator.push<Item>(
      context,
      MaterialPageRoute(builder: (_) => EditItemScreen(item: _item)),
    );

    if (updated != null) {
      final itemProvider = context.read<ItemProvider>();
      itemProvider.updateItemLocal(updated);

      final types = context.read<ItemTypeProvider>();
      types.attachItems(itemProvider.items);

      setState(() {
        _item = updated;
      });
    }
  }

  Widget infoTile(String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(color: AppColors.purple)),
          const SizedBox(height: 4),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.dialogBackground,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.purple.withOpacity(0.3)),
            ),
            child: Text(
              value,
              style: const TextStyle(color: AppColors.pink, fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tagProv = context.watch<TagProvider>();
    final tagNames = tagProv
        .tagsForItem(_item.tagIds)
        .map((t) => t.name)
        .toList();
    return Scaffold(
      backgroundColor: AppColors.primaryBackground,
      appBar: AppBar(
        backgroundColor: AppColors.primaryBackground,
        iconTheme: const IconThemeData(color: AppColors.purple),
        title: const Text(
          "Item details",
          style: TextStyle(color: AppColors.purple),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit, color: AppColors.pink),
            onPressed: _openEdit,
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          infoTile("Description", _item.description ?? "-"),
          infoTile("Quantity", _item.quantity.toString()),
          infoTile("Unit", _item.displayMeasurementUnit),
          infoTile(
            "Expiration date",
            _item.expirationDate != null
                ? _formatDate(_item.expirationDate!)
                : "-",
          ),

          infoTile(
            "Purchase price",
            _item.purchasePrice?.toStringAsFixed(2) ?? "-",
          ),
          infoTile("Tags", tagNames.isEmpty ? "-" : tagNames.join(", ")),
        ],
      ),
    );
  }
}

String _formatDate(DateTime date) {
  final displayDate = date.toLocal();
  return '${displayDate.day.toString().padLeft(2, '0')}.${displayDate.month.toString().padLeft(2, '0')}.${displayDate.year}';
}
