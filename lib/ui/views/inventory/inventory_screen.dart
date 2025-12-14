import 'package:flutter/material.dart';
import 'package:pocketeer_mobile/data/models/unit.dart';
import 'package:pocketeer_mobile/ui/widgets/custom_floating_button.dart';
import 'package:provider/provider.dart';

import 'package:pocketeer_mobile/data/models/item_types/item_type.dart';
import 'package:pocketeer_mobile/data/models/item_types/item_type_create_request.dart';
import 'package:pocketeer_mobile/providers/item_provider.dart';
import 'package:pocketeer_mobile/providers/item_type_provider.dart';
import 'package:pocketeer_mobile/theme/app_theme.dart';
import 'package:pocketeer_mobile/ui/views/inventory/item_screens/items_menu_screen.dart';
import 'package:pocketeer_mobile/ui/views/inventory/item_type_screens/add_item_type_screen.dart';
import 'package:pocketeer_mobile/ui/views/inventory/item_type_screens/show_item_type_screen.dart';
import 'package:pocketeer_mobile/ui/widgets/custom_dialog.dart';
import 'package:pocketeer_mobile/ui/widgets/item_type_card.dart';

class InventoryScreen extends StatefulWidget {
  const InventoryScreen({super.key});

  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen>
    with AutomaticKeepAliveClientMixin {
  final Set<int> _selected = {};

  Future<bool> _confirmDelete({required String message}) async {
    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return CustomDialog(
          label: 'Delete',
          confirmationText: message,
          dialogFunction: () async {
            Navigator.of(dialogContext).pop(true);
          },
        );
      },
    );

    return confirmed ?? false;
  }

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      final itemProvider = context.read<ItemProvider>();
      final typeProvider = context.read<ItemTypeProvider>();

      await itemProvider.loadAllItems();
      await typeProvider.loadItemTypes();

      typeProvider.attachItems(itemProvider.items);
    });
  }

  void _toggleSelection(int id) {
    setState(() {
      if (_selected.contains(id)) {
        _selected.remove(id);
      } else {
        _selected.add(id);
      }
    });
  }

  Future<void> _deleteSelected() async {
    if (_selected.isEmpty) return;

    final confirmed = await _confirmDelete(
      message: 'Are you sure you want to delete ${_selected.length} item(s)?',
    );
    if (!confirmed) return;

    final provider = context.read<ItemTypeProvider>();

    for (final id in _selected) {
      await provider.deleteItemType(id);
    }

    setState(() => _selected.clear());
  }

  Future<void> _deleteItemType(ItemType itemType) async {
    final confirmed = await _confirmDelete(
      message: 'Are you sure you want to delete "${itemType.name}"?',
    );
    if (!confirmed) return;
    if (!mounted) return;

    await context.read<ItemTypeProvider>().deleteItemType(itemType.id);
    setState(() => _selected.remove(itemType.id));
  }

  Future<void> _openAddItemType() async {
    final createdRequest = await Navigator.push<ItemTypeCreateRequest>(
      context,
      MaterialPageRoute(builder: (_) => const AddItemTypeScreen()),
    );

    if (createdRequest != null) {
      await context.read<ItemTypeProvider>().addItemType(createdRequest);
    }
  }

  Future<void> _openShowInfo(ItemType itemType) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ShowItemTypeScreen(itemType: itemType)),
    );

    setState(() {});
  }

  void _openItems(ItemType itemType) {
    if (_selected.isNotEmpty) {
      _toggleSelection(itemType.id);
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => ItemsMenuScreen(itemType: itemType)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final provider = context.watch<ItemTypeProvider>();
    final itemTypes = provider.itemTypes;
    final loading = provider.loading;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _selected.isEmpty ? "" : "${_selected.length} selected",
          style: const TextStyle(color: AppColors.pink),
        ),
        actions: _selected.isNotEmpty
            ? [
                IconButton(
                  icon: const Icon(Icons.delete),
                  color: AppColors.pink,
                  onPressed: _deleteSelected,
                ),
              ]
            : [],
      ),
      floatingActionButton: CustomFloatingButton(onPressed: _openAddItemType),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(8),
              child: GridView.builder(
                itemCount: itemTypes.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.78,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                ),
                itemBuilder: (_, i) {
                  final itemType = itemTypes[i];
                  final isSelected = _selected.contains(itemType.id);
                  final total = context.watch<ItemProvider>().getTotalQuantity(
                    itemType.id,
                    itemType.baseMeasurementUnit,
                    itemType.displayMeasurementUnit,
                  );
                  final expirationStatus = context
                      .watch<ItemProvider>()
                      .getTypeExpirationStatus(itemType.id);
                  final threshold = itemType.shortageThreshold;
                  final isShortage = () {
                    if (threshold == null || threshold <= 0) return false;
                    final baseUnit = findUnit(itemType.baseMeasurementUnit);
                    final displayUnit = findUnit(
                      itemType.displayMeasurementUnit,
                    );
                    final convertedThreshold = convert(
                      threshold,
                      baseUnit,
                      displayUnit,
                    );
                    return total <= convertedThreshold;
                  }();

                  return ItemTypeCard(
                    itemType: itemType,
                    isSelected: isSelected,
                    imageUrl: null,
                    pictureId: itemType.pictureId,
                    totalQuantity: total,
                    expirationStatus: expirationStatus,
                    isShortage: isShortage,
                    onTap: () => _openItems(itemType),
                    onLongPress: () => _toggleSelection(itemType.id),
                    onOpen: () => _openShowInfo(itemType),
                    onDelete: () {
                      _deleteItemType(itemType);
                    },
                  );
                },
              ),
            ),
    );
  }
}
