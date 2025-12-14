import 'package:pocketeer_mobile/data/models/resource_reservations/resource_reservation.dart';
import 'package:pocketeer_mobile/data/models/resource_specifications/resource_type.dart';

class _Sentinel {
  const _Sentinel();
}

const _undefined = _Sentinel();

class ResourceSpecification {
  final int id;
  final int projectId;
  final int itemTypeId;
  final ResourceType resourceType;
  final double plannedQuantity;
  final List<ResourceReservation>? reservations;

  ResourceSpecification({
    required this.id,
    required this.projectId,
    required this.itemTypeId,
    required this.resourceType,
    this.plannedQuantity = 0.0,
    this.reservations,
  });

  String get resourceTypeLabel {
    switch (resourceType) {
      case ResourceType.tool:
        return 'Tool';
      case ResourceType.consumable:
        return 'Material';
    }
  }

  ResourceSpecification copyWith({
    int? id,
    int? projectId,
    int? itemTypeId,
    ResourceType? resourceType,
    double? plannedQuantity,
    Object? reservations = _undefined,
  }) {
    return ResourceSpecification(
      id: id ?? this.id,
      projectId: projectId ?? this.projectId,
      itemTypeId: itemTypeId ?? this.itemTypeId,
      resourceType: resourceType ?? this.resourceType,
      plannedQuantity: plannedQuantity ?? this.plannedQuantity,
      reservations: reservations == _undefined
          ? this.reservations
          : reservations as List<ResourceReservation>?,
    );
  }

  factory ResourceSpecification.fromJson(Map<String, dynamic> json) {
    return ResourceSpecification(
      id: json['id'] as int,
      projectId: json['project_id'] as int,
      itemTypeId: json['item_type_id'] as int,
      resourceType: ResourceType.fromJson(json['resource_type'] as String),
      plannedQuantity: (json['planned_quantity'] as num?)?.toDouble() ?? 0.0,
      reservations: json['resource_reservations'] != null
          ? (json['resource_reservations'] as List)
                .map((e) => ResourceReservation.fromJson(e))
                .toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'project_id': projectId,
      'item_type_id': itemTypeId,
      'resource_type': resourceType.name,
      'planned_quantity': plannedQuantity,
      if (reservations != null)
        'resource_reservations': reservations!.map((e) => e.toJson()).toList(),
    };
  }
}
