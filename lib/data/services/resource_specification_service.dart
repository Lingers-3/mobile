import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:pocketeer_mobile/data/models/resource_specifications/resource_specification.dart';
import 'package:pocketeer_mobile/data/models/resource_specifications/resource_specification_create_request.dart';
import 'package:pocketeer_mobile/data/models/resource_specifications/resource_type.dart';
import 'package:pocketeer_mobile/data/models/resource_specifications/resource_specification_update_request.dart';

class ResourceSpecificationMock {
  static final latency = Duration(milliseconds: 800);

  static final specifications = [
    ResourceSpecification(
      id: 1,
      projectId: 1,
      itemTypeId: 61,
      resourceType: ResourceType.consumable,
      plannedQuantity: 100.0,
    ),
  ];
}

class ResourceSpecificationService {
  // TODO: use real implementation when backend is ready
  Future<List<ResourceSpecification>> getAllSpecificationsByProjectId(
    int projectId,
  ) async {
    await Future.delayed(ResourceSpecificationMock.latency);

    if (kDebugMode) {
      print(
        '📥 (Mock) Fetched ${ResourceSpecificationMock.specifications.length} specifications',
      );
    }

    return ResourceSpecificationMock.specifications
        .where((s) => s.projectId == projectId)
        .toList();
  }

  Future<ResourceSpecification> getSpecification(int id) async {
    await Future.delayed(ResourceSpecificationMock.latency);

    try {
      final specification = ResourceSpecificationMock.specifications.firstWhere(
        (e) => e.id == id,
      );
      return specification;
    } catch (e) {
      throw Exception('Specification not found');
    }
  }

  Future<ResourceSpecification> createSpecification(
    ResourceSpecificationCreateRequest request,
  ) async {
    await Future.delayed(ResourceSpecificationMock.latency);

    final newId = ResourceSpecificationMock.specifications.isNotEmpty
        ? ResourceSpecificationMock.specifications
                  .map((e) => e.id)
                  .reduce(max) +
              1
        : 1;

    final newSpecification = ResourceSpecification(
      id: newId,
      projectId: request.projectId,
      itemTypeId: request.itemTypeId,
      resourceType: request.resourceType,
      plannedQuantity: request.plannedQuantity,
    );

    ResourceSpecificationMock.specifications.add(newSpecification);

    if (kDebugMode) {
      print(
        '✅ (Mock) Specification created: ${jsonEncode(newSpecification.toJson())}',
      );
    }

    return newSpecification;
  }

  Future<ResourceSpecification> updateSpecification(
    int id,
    ResourceSpecificationUpdateRequest request,
  ) async {
    await Future.delayed(ResourceSpecificationMock.latency);

    final index = ResourceSpecificationMock.specifications.indexWhere(
      (e) => e.id == id,
    );
    if (index == -1) {
      throw Exception('Specification not found');
    }

    final oldItem = ResourceSpecificationMock.specifications[index];
    final updatedItem = ResourceSpecification(
      id: oldItem.id,
      projectId: oldItem.projectId,
      itemTypeId: oldItem.itemTypeId,
      resourceType: oldItem.resourceType,
      plannedQuantity: request.plannedQuantity,
    );

    ResourceSpecificationMock.specifications[index] = updatedItem;

    if (kDebugMode) {
      print(
        '✅ (Mock) Specification updated: ${jsonEncode(updatedItem.toJson())}',
      );
    }

    return updatedItem;
  }

  Future<void> deleteSpecification(int id) async {
    await Future.delayed(ResourceSpecificationMock.latency);

    final index = ResourceSpecificationMock.specifications.indexWhere(
      (e) => e.id == id,
    );
    if (index == -1) {
      throw Exception('Specification not found');
    }

    ResourceSpecificationMock.specifications.removeWhere((s) => s.id == id);

    if (kDebugMode) {
      print('🗑️ (Mock) Specification deleted: ID $id');
    }
  }
}
