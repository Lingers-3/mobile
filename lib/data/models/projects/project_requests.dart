import 'package:pocketeer_mobile/data/models/resource_specifications/resource_type.dart';

class ProjectPlanResourceRequest {
  final int itemTypeId;
  final double plannedQuantity;
  final ResourceType resourceType;

  ProjectPlanResourceRequest({
    required this.itemTypeId,
    required this.plannedQuantity,
    required this.resourceType,
  });

  Map<String, dynamic> toJson() {
    return {
      'item_type_id': itemTypeId,
      'planned_quantity': plannedQuantity,
      'resource_type': resourceType,
    };
  }
}

class ProjectAddResourceSpecificationRequest {
  final int itemTypeId;
  final ResourceType resourceType;
  final double plannedQuantity;

  ProjectAddResourceSpecificationRequest({
    required this.itemTypeId,
    required this.resourceType,
    required this.plannedQuantity,
  });

  Map<String, dynamic> toJson() {
    return {
      'item_type_id': itemTypeId,
      'resource_type': resourceType,
      'planned_quantity': plannedQuantity,
    };
  }
}

class ProjectAddResourceReservationRequest {
  final int itemId;
  final double reservedQuantity;
  final double usedQuantity;

  ProjectAddResourceReservationRequest({
    required this.itemId,
    required this.reservedQuantity,
    required this.usedQuantity,
  });

  Map<String, dynamic> toJson() {
    return {
      'item_id': itemId,
      'reserved': reservedQuantity,
      'used': usedQuantity,
    };
  }
}

class ProjectCreateRequest {
  final String name;
  final String? description;
  final DateTime? plannedDeadline;
  final double? plannedIncome;
  final int? plannedWorkTime;

  ProjectCreateRequest({
    required this.name,
    this.description,
    this.plannedDeadline,
    this.plannedIncome,
    this.plannedWorkTime,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'planned_deadline': plannedDeadline?.toUtc().toIso8601String(),
      'planned_income': plannedIncome,
      'planned_work_time': plannedWorkTime,
    };
  }
}

class ProjectUpdateActualRequest {
  final DateTime? actualDeadline;
  final double? actualIncome;
  final int? actualWorkTime;

  ProjectUpdateActualRequest({
    this.actualDeadline,
    this.actualIncome = 0.0,
    this.actualWorkTime = 0,
  });

  Map<String, dynamic> toJson() {
    return {
      'actual_deadline': actualDeadline?.toUtc().toIso8601String(),
      'actual_income': actualIncome,
      'actual_work_time': actualWorkTime,
    };
  }
}

class ProjectUpdatePlanRequest {
  final DateTime? plannedDeadline;
  final double? plannedIncome;
  final int? plannedWorkTime;

  ProjectUpdatePlanRequest({
    required this.plannedDeadline,
    required this.plannedIncome,
    required this.plannedWorkTime,
  });

  Map<String, dynamic> toJson() {
    return {
      'planned_deadline': plannedDeadline?.toUtc().toIso8601String(),
      'planned_income': plannedIncome,
      'planned_work_time': plannedWorkTime,
    };
  }
}

class ProjectUpdateRequest {
  final String name;
  final String? description;

  ProjectUpdateRequest({required this.name, required this.description});

  Map<String, dynamic> toJson() {
    return {'name': name, 'description': description};
  }
}

class ProjectUpdateResourceReservation {
  final double reservedQuantity;
  final double usedQuantity;

  ProjectUpdateResourceReservation({
    required this.reservedQuantity,
    required this.usedQuantity,
  });

  Map<String, dynamic> toJson() {
    return {'reserved': reservedQuantity, 'used': usedQuantity};
  }
}
