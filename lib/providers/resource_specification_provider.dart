import 'package:flutter/material.dart';
import 'package:pocketeer_mobile/data/models/resource_specifications/resource_specification.dart';
import 'package:pocketeer_mobile/data/models/resource_specifications/resource_specification_create_request.dart';
import 'package:pocketeer_mobile/data/models/resource_specifications/resource_specification_update_request.dart';
import 'package:pocketeer_mobile/data/models/resource_specifications/resource_type.dart';
import 'package:pocketeer_mobile/data/services/resource_specification_service.dart';

class ResourceSpecificationProvider extends ChangeNotifier {
  final ResourceSpecificationService _service = ResourceSpecificationService();
  bool _isLoading = false;
  String? _error;
  List<ResourceSpecification> _specifications = [];

  List<ResourceSpecification> get specifications => _specifications;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadSpecification(int projectId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _specifications = await _service.getAllSpecificationsByProjectId(
        projectId,
      );
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Метод для отримання специфікації за ID
  ResourceSpecification getById(int id) {
    return _specifications.firstWhere((s) => s.id == id);
  }

  void addSpecification(
    int projectId,
    int itemTypeId,
    ResourceType resourceType,
    double? plannedQuantity,
  ) async {
    try {
      final request = ResourceSpecificationCreateRequest(
        projectId: projectId,
        itemTypeId: itemTypeId,
        resourceType: resourceType,
        plannedQuantity: plannedQuantity ?? 0,
      );

      final newSpecification = await _service.createSpecification(request);

      _specifications.add(newSpecification);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<void> updateSpecification(int id, double plannedQuantity) async {
    try {
      final request = ResourceSpecificationUpdateRequest(
        plannedQuantity: plannedQuantity,
      );

      final updatedSpecification = await _service.updateSpecification(
        id,
        request,
      );

      final index = _specifications.indexWhere((s) => s.id == id);
      if (index != -1) {
        _specifications[index] = updatedSpecification;
        notifyListeners();
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<void> deleteSpecification(int id) async {
    try {
      await _service.deleteSpecification(id);

      _specifications.removeWhere((s) => s.id == id);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  // Допоміжний метод для генерації ID (для mock-режиму)
  int generateId() {
    if (_specifications.isEmpty) return 1;
    return _specifications.map((e) => e.id).reduce((a, b) => a > b ? a : b) + 1;
  }

  // У майбутньому тут будуть методи loadSpecifications(projectId), createSpecification(...)
}
