import 'package:flutter/material.dart';
import 'package:pocketeer_mobile/data/models/resource_specifications/resource_specification.dart';

class ResourceSpecificationProvider extends ChangeNotifier {
  // MOCK DATA: Симулюємо специфікацію для проекту №1
  // Припустимо, itemTypeId: 1 - це якийсь тип предмету, який є у вас в базі
  final List<ResourceSpecification> _specifications = [
    ResourceSpecification(
      id: 1,
      projectId: 1,
      itemTypeId:
          61, // ВАЖЛИВО: Цей ID має співпадати з реальним ItemType у вашій базі для тесту
      resourceType: ResourceType.material,
      plannedQuantity: 100.0,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
  ];

  List<ResourceSpecification> get specifications => _specifications;

  // Метод для отримання специфікації за ID
  ResourceSpecification getById(int id) {
    return _specifications.firstWhere((s) => s.id == id);
  }

  void addSpecification(ResourceSpecification spec) {
    _specifications.add(spec);
    notifyListeners();
  }

  // Допоміжний метод для генерації ID (для mock-режиму)
  int generateId() {
    if (_specifications.isEmpty) return 1;
    return _specifications.map((e) => e.id).reduce((a, b) => a > b ? a : b) + 1;
  }

  // У майбутньому тут будуть методи loadSpecifications(projectId), createSpecification(...)
}
