import 'package:flutter/foundation.dart';
import 'package:pocketeer_mobile/data/models/items/item.dart';
import 'package:pocketeer_mobile/data/models/item_types/item_type.dart';
import 'package:pocketeer_mobile/data/models/item_types/item_type_create_request.dart';
import 'package:pocketeer_mobile/data/models/item_types/item_type_update_request.dart';
import 'package:pocketeer_mobile/data/services/item_type_service.dart';

class ItemTypeProvider extends ChangeNotifier {
  final ItemTypeService _service = ItemTypeService();

  List<ItemType> _itemTypes = [];
  bool _loaded = false;
  bool _loading = false;

  List<ItemType> get itemTypes => _itemTypes;
  bool get loading => _loading;

  List<Item> _items = [];

  Future<void> loadItemTypes() async {
    if (_loaded) return;

    _loading = true;
    notifyListeners();

    try {
      _itemTypes = await _service.getAllItemTypes();
      _loaded = true;

      if (_items.isNotEmpty) {
        _recalculateTotals();
      }
    } catch (e) {
      if (kDebugMode) print("❌ loadItemTypes error: $e");
    }

    _loading = false;
    notifyListeners();
  }

  void attachItems(List<Item> items) {
    _items = items;
    _recalculateTotals();
    notifyListeners();
  }

  void _recalculateTotals() {
    for (final type in _itemTypes) {
      final sum = _items
          .where((i) => i.itemTypeId == type.id)
          .fold(0.0, (s, it) => s + it.quantity);

      type.totalQuantity = sum;
    }
  }

  Future<ItemType?> addItemType(ItemTypeCreateRequest request) async {
    try {
      final newItem = await _service.createItemType(request);
      newItem.totalQuantity = 0;

      _itemTypes.add(newItem);
      notifyListeners();
      return newItem;
    } catch (e) {
      if (kDebugMode) print("❌ addItemType error: $e");
      return null;
    }
  }

  Future<void> deleteItemType(int id) async {
    try {
      await _service.deleteItemType(id);
      _itemTypes.removeWhere((e) => e.id == id);
      notifyListeners();
    } catch (e) {
      if (kDebugMode) print("❌ deleteItemType error: $e");
    }
  }

  Future<ItemType?> updateItemType(
    int id,
    ItemTypeUpdateRequest request,
  ) async {
    try {
      final updated = await _service.updateItemType(id, request);

      final index = _itemTypes.indexWhere((e) => e.id == id);
      if (index != -1) {
        final oldSum = _itemTypes[index].totalQuantity;
        updated.totalQuantity = oldSum;

        _itemTypes[index] = updated;
      }

      notifyListeners();
      return updated;
    } catch (e) {
      if (kDebugMode) print("❌ updateItemType error: $e");
      return null;
    }
  }

  void replaceItem(ItemType updated) {
    final index = _itemTypes.indexWhere((e) => e.id == updated.id);
    if (index != -1) {
      _itemTypes[index] = updated;
      notifyListeners();
    }
  }

  Future<void> reload() async {
    _loaded = false;
    return await loadItemTypes();
  }
}
