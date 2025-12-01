import 'package:flutter/material.dart';
import 'package:pocketeer_mobile/providers/item_provider.dart';
import 'package:pocketeer_mobile/providers/item_type_provider.dart';
import 'package:pocketeer_mobile/ui/widgets/custom_dialog.dart';
import 'package:pocketeer_mobile/ui/widgets/item_card.dart';
import 'package:provider/provider.dart';
import 'package:pocketeer_mobile/data/models/item_types/item_type.dart';
import 'package:pocketeer_mobile/data/models/items/item.dart';
import 'package:pocketeer_mobile/data/models/items/item_create_request.dart';
import 'package:pocketeer_mobile/theme/app_theme.dart';
import 'package:pocketeer_mobile/ui/views/inventory/item_screens/add_item_screen.dart';
import 'package:pocketeer_mobile/ui/views/inventory/item_screens/show_item_screen.dart';

class ItemsMenuScreen extends StatefulWidget {
  final ItemType itemType;

  const ItemsMenuScreen({super.key, required this.itemType});

  @override
  State<ItemsMenuScreen> createState() => _ItemsMenuScreenState();
}

class _ItemsMenuScreenState extends State<ItemsMenuScreen> {
  final Set<int> _selected = {};

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      final provider = context.read<ItemProvider>();
      if (provider.items.isEmpty) {
        provider.loadAllItems();
      }
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
    final itemProvider = context.read<ItemProvider>();
    final typeProvider = context.read<ItemTypeProvider>();

    for (final id in _selected) {
      await itemProvider.deleteItem(id);
    }

    _selected.clear();

    typeProvider.attachItems(itemProvider.items);

    setState(() {});
  }

  Future<void> _openAddItem() async {
    final createdRequest = await Navigator.push<ItemCreateRequest>(
      context,
      MaterialPageRoute(
        builder: (_) => AddItemScreen(
          itemTypeId: widget.itemType.id,
          itemTypeName: widget.itemType.name,
          baseUnit: widget.itemType.baseMeasurementUnit,
          defaultQuantity: widget.itemType.defaultQuantity,
        ),
      ),
    );

    if (createdRequest != null) {
      final itemProvider = context.read<ItemProvider>();

      try {
        final newItem = await itemProvider.itemService.createItem(
          createdRequest,
        );
        itemProvider.addItem(newItem);

        context.read<ItemTypeProvider>().attachItems(itemProvider.items);
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Помилка додавання айтема: $e')),
          );
        }
      }
    }
  }

  void _confirmDeleteItem(Item item) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (_) => CustomDialog(
        label: "Delete item?",
        confirmationText: "Are you sure you want to delete this item?",
        dialogFunction: () async {
          final itemProvider = context.read<ItemProvider>();
          final typeProvider = context.read<ItemTypeProvider>();

          await itemProvider.deleteItem(item.id);
          typeProvider.attachItems(itemProvider.items);

          Navigator.of(context).pop();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final itemProvider = context.watch<ItemProvider>();
    final items = itemProvider.getItemsByType(widget.itemType.id);
    final loading = itemProvider.loading;

    return Scaffold(
      backgroundColor: AppColors.primaryBackground,
      appBar: AppBar(
        iconTheme: const IconThemeData(color: AppColors.purple),
        backgroundColor: AppColors.primaryBackground,
        title: Text(
          _selected.isEmpty
              ? "${widget.itemType.name} Items"
              : "${_selected.length} selected",
          style: TextStyle(
            color: _selected.isEmpty ? AppColors.purple : AppColors.pink,
          ),
        ),
        actions: _selected.isNotEmpty
            ? [
                IconButton(
                  icon: const Icon(Icons.delete, color: AppColors.pink),
                  onPressed: _deleteSelected,
                ),
              ]
            : [],
      ),
      floatingActionButton: _selected.isEmpty
          ? FloatingActionButton(
              onPressed: _openAddItem,
              backgroundColor: AppColors.pink,
              child: const Icon(Icons.add, color: AppColors.primaryBackground),
            )
          : null,
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : items.isEmpty
          ? Center(
              child: Text(
                'None of item type: "${widget.itemType.name}".\nTap + to add new items.',
                style: const TextStyle(color: AppColors.purple),
                textAlign: TextAlign.center,
              ),
            )
          : GridView.builder(
              padding: const EdgeInsets.all(12),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 0.78,
              ),
              itemCount: items.length,
              itemBuilder: (_, index) {
                final item = items[index];
                final isSelected = _selected.contains(item.id);

                return GestureDetector(
                  onLongPress: () => _toggleSelection(item.id),
                  onTap: () {
                    if (_selected.isNotEmpty) {
                      _toggleSelection(item.id);
                    } else {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ShowItemScreen(item: item),
                        ),
                      );
                    }
                  },
                  child: Stack(
                    children: [
                      ItemCard(
                        item: item,
                        onEdit: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ShowItemScreen(item: item),
                            ),
                          );
                        },
                        onDelete: () => _confirmDeleteItem(item),
                      ),
                      if (isSelected)
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.35),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.check_circle,
                              size: 48,
                              color: Colors.white,
                            ),
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
