import 'package:flutter/material.dart';
import 'package:pocketeer_mobile/data/models/unit.dart';
import 'package:pocketeer_mobile/ui/widgets/custom_filter_drawer.dart';
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

  String _searchQuery = '';
  String _sortCriteria = 'date_desc';
  final TextEditingController _searchController = TextEditingController();

  void _setSortCriteria(String? newCriteria) {
    if (newCriteria != null) {
      setState(() {
        _sortCriteria = newCriteria;
      });
    }
  }

  void _onSearchChanged(String newQuery) {
    setState(() {
      _searchQuery = newQuery;
    });
  }

  List<ItemType> _getFilteredAndSortedItemTypes(List<ItemType> originalList) {
    print(
      'Filtering started. Original count: ${originalList.length}. Query: $_searchQuery',
    );
    List<ItemType> filteredList = originalList;

    if (_searchQuery.isNotEmpty) {
      filteredList = filteredList.where((itemType) {
        return itemType.name.toLowerCase().contains(_searchQuery.toLowerCase());
      }).toList();
    }

    filteredList.sort((a, b) {
      switch (_sortCriteria) {
        case 'name_asc':
          return a.name.compareTo(b.name);
        case 'name_desc':
          return b.name.compareTo(a.name);
        case 'date_asc':
          return a.createdAt.compareTo(b.createdAt);
        case 'date_desc':
          return b.createdAt.compareTo(a.createdAt);
      }

      return 0;
    });

    print('Filtering finished. Filtered count: ${filteredList.length}');
    return filteredList;
  }

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

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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
    final originalItemTypes = provider.itemTypes;
    final loading = provider.loading;

    final itemTypes = _getFilteredAndSortedItemTypes(originalItemTypes);

    return Scaffold(
      appBar: AppBar(
        leading: null,
        automaticallyImplyLeading: false,

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

      drawer: CustomFilterDrawer(
        searchController: _searchController,
        currentSearchQuery: _searchQuery,
        currentSortCriteria: _sortCriteria,
        onSortChanged: _setSortCriteria,
        widthFactor: 0.5,
        onSearchChanged: _onSearchChanged,
      ),

      floatingActionButton: CustomFloatingButton(onPressed: _openAddItemType),

      body: Stack(
        children: [
          loading
              ? const Center(child: CircularProgressIndicator())
              : Padding(
                  padding: const EdgeInsets.all(8),
                  child: GridView.builder(
                    itemCount: itemTypes.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.78,
                          crossAxisSpacing: 8,
                          mainAxisSpacing: 8,
                        ),
                    itemBuilder: (_, i) {
                      final itemType = itemTypes[i];
                      final isSelected = _selected.contains(itemType.id);
                      final itemProvider = context.watch<ItemProvider>();
                      final total = itemProvider.getTotalQuantity(
                        itemType.id,
                        itemType.baseMeasurementUnit,
                        itemType.displayMeasurementUnit,
                      );
                      final expirationStatus = itemProvider
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

          Positioned(
            left: 0,
            top: MediaQuery.of(context).size.height * 0.3,
            child: Builder(
              builder: (innerContext) {
                return IconButton(
                  icon: const Icon(
                    Icons.filter_list,
                    color: AppColors.pink,
                    size: 30,
                  ),
                  style: IconButton.styleFrom(
                    shadowColor: AppColors.pink,
                    backgroundColor: AppColors.primaryBackground,
                    minimumSize: const Size(40, 60),
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.only(
                        topRight: Radius.circular(10),
                        bottomRight: Radius.circular(10),
                      ),
                    ),
                    padding: const EdgeInsets.only(right: 12),
                    elevation: 4, // Небольшая тень
                  ),
                  onPressed: () {
                    Scaffold.of(innerContext).openDrawer();
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
