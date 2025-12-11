import 'package:flutter/foundation.dart';
import 'package:pocketeer_mobile/data/models/resource_reservations/resource_reservation.dart';
import 'package:pocketeer_mobile/data/models/resource_reservations/resource_reservation_create_request.dart';
import 'package:pocketeer_mobile/data/models/resource_reservations/resource_reservation_update_request.dart';
import 'package:pocketeer_mobile/data/services/resource_reservation_service.dart';

class ResourceReservationProvider extends ChangeNotifier {
  final ResourceReservationService _service = ResourceReservationService();

  List<ResourceReservation> _reservations = [];
  bool _isLoading = false;
  String? _error;

  List<ResourceReservation> get reservations => _reservations;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadReservations() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _reservations = await _service.getAllReservations();
    } catch (e) {
      _error = e.toString();
      if (kDebugMode) {
        print('Error loading reservations: $e');
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addReservation(int itemId, double quantity) async {
    try {
      final request = ResourceReservationCreateRequest(
        itemId: itemId,
        reservedQuantity: quantity,
      );

      final newReservation = await _service.createReservation(request);

      _reservations.add(newReservation);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<void> updateReservation(
    int id, {
    double? reservedQuantity,
    double? usedQuantity,
  }) async {
    try {
      final request = ResourceReservationUpdateRequest(
        reservedQuantity: reservedQuantity,
        usedQuantity: usedQuantity,
      );

      final updatedReservation = await _service.updateReservation(id, request);

      final index = _reservations.indexWhere((r) => r.id == id);
      if (index != -1) {
        _reservations[index] = updatedReservation;
        notifyListeners();
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<void> deleteReservation(int id) async {
    try {
      await _service.deleteReservation(id);

      _reservations.removeWhere((r) => r.id == id);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  List<ResourceReservation> getReservationsByItemId(int itemId) {
    return _reservations.where((r) => r.itemId == itemId).toList();
  }
}
