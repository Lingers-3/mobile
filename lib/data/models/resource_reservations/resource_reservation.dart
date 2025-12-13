class ResourceReservation {
  final int id;
  final int resourceSpecificationId;
  final int itemId;
  final double reservedQuantity;
  final double usedQuantity;

  ResourceReservation({
    required this.id,
    required this.resourceSpecificationId,
    required this.itemId,
    required this.reservedQuantity,
    this.usedQuantity = 0.0,
  });

  factory ResourceReservation.fromJson(Map<String, dynamic> json) {
    return ResourceReservation(
      id: json['id'] as int,
      resourceSpecificationId: json['resource_specification_id'],
      itemId: json['item_id'] as int,
      reservedQuantity: (json['reserved_quantity'] as num).toDouble(),
      usedQuantity: (json['used_quantity'] as num? ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'resource_specification_id': resourceSpecificationId,
      'item_id': itemId,
      'reserved_quantity': reservedQuantity,
      'used_quantity': usedQuantity,
    };
  }
}
