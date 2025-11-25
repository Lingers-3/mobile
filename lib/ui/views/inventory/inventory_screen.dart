import 'package:flutter/material.dart';
import 'package:pocketeer_mobile/data/models/item_type_create_request.dart';
import 'package:provider/provider.dart';
import 'package:pocketeer_mobile/data/models/item_type.dart';
import 'package:pocketeer_mobile/providers/item_type_provider.dart';
import 'package:pocketeer_mobile/theme/app_theme.dart';
import 'package:pocketeer_mobile/ui/widgets/item_type_card.dart';
import 'package:pocketeer_mobile/ui/views/inventory/add_item_type_screen.dart';
import 'package:pocketeer_mobile/ui/views/inventory/show_item_type_screen.dart';

class InventoryScreen extends StatefulWidget {
  const InventoryScreen({super.key});

  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  final Set<int> _selected = {};

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<ItemTypeProvider>().loadItemTypes();
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
    final provider = context.read<ItemTypeProvider>();

    for (final id in _selected) {
      await provider.deleteItemType(id);
    }

    setState(() => _selected.clear());
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
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text("Open items of '${itemType.name}'")));
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ItemTypeProvider>();
    final itemTypes = provider.itemTypes;
    final loading = provider.loading;

    return Scaffold(
      backgroundColor: AppColors.primaryBackground,
      appBar: AppBar(
        backgroundColor: AppColors.primaryBackground,
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
      floatingActionButton: FloatingActionButton(
        onPressed: _openAddItemType,
        backgroundColor: AppColors.pink,
        child: const Icon(Icons.add),
      ),
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

                  return ItemTypeCard(
                    itemType: itemType,
                    isSelected: isSelected,
                    imageUrl: null,

                    onTap: () => _openItems(itemType),
                    onLongPress: () => _toggleSelection(itemType.id),
                    onOpen: () => _openShowInfo(itemType),

                    onDelete: () async {
                      await provider.deleteItemType(itemType.id);
                      setState(() {});
                    },
                  );
                },
              ),
            ),
    );
  }
}
