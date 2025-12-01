import 'package:flutter/foundation.dart';
import 'package:pocketeer_mobile/data/models/items/item.dart';
import 'package:pocketeer_mobile/data/services/item_service.dart';
import 'package:pocketeer_mobile/data/models/unit.dart';

enum ItemExpirationStatus { none, expiring, expired }

class ItemProvider extends ChangeNotifier {
  final ItemService _itemService = ItemService();
  ItemService get itemService => _itemService;

  List<Item> _items = [];
  bool _loading = false;
  String? _error;

  List<Item> get items => _items;
  bool get loading => _loading;
  String? get errorMessage => _error;

  Future<void> loadAllItems() async {
    _loading = true;
    notifyListeners();

    try {
      _items = await _itemService.getAllItems();
    } catch (e) {
      _error = e.toString();
    }

    _loading = false;
    notifyListeners();
  }

  List<Item> getItemsByType(int typeId) =>
      _items.where((i) => i.itemTypeId == typeId).toList();

  double getTotalQuantity(
    int typeId,
    String baseUnitBackend,
    String displayUnitBackend,
  ) {
    final baseUnit = findUnit(baseUnitBackend);
    final displayUnit = findUnit(displayUnitBackend);

    final baseTotal = _items.where((i) => i.itemTypeId == typeId).fold(0.0, (
      sum,
      item,
    ) {
      final itemUnit = findUnit(item.displayMeasurementUnit);
      final asBase = convert(item.quantity, itemUnit, baseUnit);
      return sum + asBase;
    });

    return convert(baseTotal, baseUnit, displayUnit);
  }

  ItemExpirationStatus getTypeExpirationStatus(int typeId) {
    final now = DateTime.now();

    final hasExpired = _items.any((item) {
      if (item.itemTypeId != typeId) return false;
      final exp = item.expirationDate;
      if (exp == null) return false;
      return exp.isBefore(now);
    });
    if (hasExpired) return ItemExpirationStatus.expired;

    final hasExpiring = _items.any((item) {
      if (item.itemTypeId != typeId) return false;
      final exp = item.expirationDate;
      if (exp == null) return false;
      final daysDiff = exp.difference(now).inDays;
      return daysDiff >= 0 && daysDiff <= 7;
    });

    if (hasExpiring) return ItemExpirationStatus.expiring;
    return ItemExpirationStatus.none;
  }

  void updateItemLocal(Item updated) {
    final idx = _items.indexWhere((i) => i.id == updated.id);
    if (idx != -1) {
      _items[idx] = updated;
      notifyListeners();
    }
  }

  Future<void> addItem(Item i) async {
    _items.add(i);
    notifyListeners();
  }

  Future<void> deleteItem(int id) async {
    await _itemService.deleteItem(id);
    _items.removeWhere((i) => i.id == id);
    notifyListeners();
  }

  bool hasExpiringItems(int typeId) {
    final now = DateTime.now();
    return _items.any((item) {
      if (item.itemTypeId != typeId) return false;
      final exp = item.expirationDate;
      if (exp == null) return false;
      if (exp.isBefore(now)) return true; // already expired
      final daysDiff = exp.difference(now).inDays;
      return daysDiff >= 0 && daysDiff <= 7; // expiring soon
    });
  }

  void updateItemsUnitForType(int typeId, String newBaseUnit) {
    bool changed = false;
    _items = _items.map((item) {
      if (item.itemTypeId != typeId) return item;
      if (item.displayMeasurementUnit == newBaseUnit) return item;
      changed = true;
      return Item(
        id: item.id,
        description: item.description,
        quantity: item.quantity,
        expirationDate: item.expirationDate,
        displayMeasurementUnit: newBaseUnit,
        purchasePrice: item.purchasePrice,
        itemTypeId: item.itemTypeId,
        tagIds: item.tagIds,
        createdAt: item.createdAt,
        updatedAt: item.updatedAt,
        deletedAt: item.deletedAt,
      );
    }).toList();

    if (changed) notifyListeners();
  }
}
