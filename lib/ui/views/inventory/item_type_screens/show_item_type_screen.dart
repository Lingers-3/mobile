import 'package:flutter/material.dart';
import 'package:pocketeer_mobile/data/models/item_types/item_type.dart';
import 'package:pocketeer_mobile/providers/tag_provider.dart';
import 'package:pocketeer_mobile/theme/app_theme.dart';
import 'package:pocketeer_mobile/ui/widgets/picture_loader.dart';
import 'package:provider/provider.dart';
import 'edit_item_type_screen.dart';

class ShowItemTypeScreen extends StatefulWidget {
  final ItemType itemType;

  const ShowItemTypeScreen({super.key, required this.itemType});

  @override
  State<ShowItemTypeScreen> createState() => _ShowItemTypeScreenState();
}

class _ShowItemTypeScreenState extends State<ShowItemTypeScreen> {
  late ItemType _itemType;

  @override
  void initState() {
    super.initState();
    _itemType = widget.itemType;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final prov = context.read<TagProvider>();
      if (prov.tags.isEmpty && !prov.loading) {
        prov.loadTags();
      }
    });
  }

  Future<void> _openEdit() async {
    final updated = await Navigator.push<ItemType>(
      context,
      MaterialPageRoute(
        builder: (_) => EditItemTypeScreen(itemType: _itemType),
      ),
    );

    if (updated != null) {
      setState(() {
        _itemType = updated;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryBackground,
      appBar: AppBar(
        backgroundColor: AppColors.primaryBackground,
        iconTheme: const IconThemeData(color: AppColors.purple),
        title: Text(
          _itemType.name,
          style: const TextStyle(color: AppColors.purple),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit, color: AppColors.pink),
            onPressed: _openEdit,
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Center(
              child: _itemType.pictureId != null
                  ? PictureLoader(
                      pictureId: _itemType.pictureId!,
                      size: 400,
                      borderRadius: 12,
                    )
                  : Container(
                      height: 400,
                      width: 400,
                      decoration: BoxDecoration(
                        color: AppColors.dialogBackground,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.image,
                        color: AppColors.purple,
                        size: 64,
                      ),
                    ),
            ),

            const SizedBox(height: 24),

            _infoTile("Name", _itemType.name),
            _infoTile("Description", _itemType.description ?? "-"),
            _infoTile("Base unit", _itemType.baseMeasurementUnit),
            _infoTile("Display unit", _itemType.displayMeasurementUnit),
            _infoTile(
              "Default quantity",
              _itemType.defaultQuantity?.toString() ?? "-",
            ),
            _infoTile(
              "Shortage threshold",
              _itemType.shortageThreshold?.toString() ?? "-",
            ),
            _buildTagsTile(context),
          ],
        ),
      ),
    );
  }

  Widget _buildTagsTile(BuildContext context) {
    final tagProv = context.watch<TagProvider>();
    final tags = tagProv.tagsForItem(_itemType.tagIds);
    final content = tags.isEmpty ? "-" : tags.map((t) => t.name).join(", ");
    return _infoTile("Tags", content);
  }

  Widget _infoTile(String title, String value) {
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
}
