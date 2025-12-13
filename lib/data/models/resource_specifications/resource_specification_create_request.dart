import 'package:pocketeer_mobile/data/models/resource_specifications/resource_type.dart';

class ResourceSpecificationCreateRequest {
  final int projectId;
  final int itemTypeId;
  final ResourceType resourceType;
  final double plannedQuantity;

  ResourceSpecificationCreateRequest({
    required this.projectId,
    required this.itemTypeId,
    required this.resourceType,
    this.plannedQuantity = 0.0,
  });

  Map<String, dynamic> toJson() {
    return {
      'project_id': projectId,
      'item_type_id': itemTypeId,
      'resource_type': resourceType.name,
      'planned_quantity': plannedQuantity,
    };
  }
}
