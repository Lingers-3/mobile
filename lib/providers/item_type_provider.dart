import 'package:flutter/foundation.dart';
import 'package:pocketeer_mobile/data/models/item_type.dart';
import 'package:pocketeer_mobile/data/models/item_type_create_request.dart';
import 'package:pocketeer_mobile/data/models/item_type_update_request.dart';
import 'package:pocketeer_mobile/data/services/item_type_service.dart';

class ItemTypeProvider extends ChangeNotifier {
  final ItemTypeService _service = ItemTypeService();

  List<ItemType> _itemTypes = [];
  bool _loaded = false;
  bool _loading = false;

  List<ItemType> get itemTypes => _itemTypes;
  bool get loading => _loading;

  Future<void> loadItemTypes() async {
    if (_loaded) return;

    _loading = true;
    notifyListeners();

    try {
      _itemTypes = await _service.getAllItemTypes();
      _loaded = true;
    } catch (e) {
      if (kDebugMode) print("❌ loadItemTypes error: $e");
    }

    _loading = false;
    notifyListeners();
  }

  Future<ItemType?> addItemType(ItemTypeCreateRequest request) async {
    try {
      final newItem = await _service.createItemType(request);
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
        _itemTypes[index] = updated;
        notifyListeners();
      }

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
