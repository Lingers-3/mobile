class ResourceSpecificationUpdateRequest {
  final double plannedQuantity;

  ResourceSpecificationUpdateRequest({required this.plannedQuantity});

  Map<String, dynamic> toJson() {
    return {'planned_quantity': plannedQuantity};
  }
}
