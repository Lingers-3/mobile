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

  ProjectAddResourceSpecificationRequest({
    required this.itemTypeId,
    required this.resourceType,
  });

  Map<String, dynamic> toJson() {
    return {
      'item_type_id': itemTypeId,
      'resource_type': resourceType,
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
      'item_type_id': itemId,
      'reserved_quantity': reservedQuantity,
      'used_quantity': usedQuantity,
    };
  }
}

class ProjectCreateRequest {
  final String name;
  final String? description;
  final DateTime? plannedDeadline;
  final double? plannedIncome;
  final String currency;
  final double? plannedWorkTime;

  ProjectCreateRequest({
    required this.name,
    this.description,
    this.plannedDeadline,
    this.plannedIncome = 0.0,
    this.currency = 'UAH',
    this.plannedWorkTime = 0.0,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'planned_deadline': plannedDeadline,
      'planned_income': plannedIncome,
      'currency': currency,
      'planned_work_time': plannedWorkTime,
    };
  }
}

class ProjectUpdateActualRequest {
  final DateTime? actualDeadline;
  final double? actualIncome;
  final String currency;
  final double? actualWorkTime;

  ProjectUpdateActualRequest({
    this.actualDeadline,
    this.actualIncome = 0.0,
    this.currency = 'UAH',
    this.actualWorkTime = 0.0,
  });

  Map<String, dynamic> toJson() {
    return {
      'actual_deadline': actualDeadline,
      'actual_income': actualIncome,
      'currency': currency,
      'actual_work_time': actualWorkTime,
    };
  }
}

class ProjectUpdatePlanRequest {
  final DateTime? plannedDeadline;
  final double? plannedIncome;
  final String currency;
  final double? plannedWorkTime;

  ProjectUpdatePlanRequest({
    required this.plannedDeadline,
    required this.plannedIncome,
    this.currency = 'UAH',
    required this.plannedWorkTime,
  });

  Map<String, dynamic> toJson() {
    return {
      'planned_deadline': plannedDeadline,
      'planned_income': plannedIncome,
      'currency': currency,
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
