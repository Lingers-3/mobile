class ResourceReservationCreateRequest {
  final int itemId;
  final int resourceSpecificationId;
  final double reservedQuantity;

  ResourceReservationCreateRequest({
    required this.itemId,
    required this.resourceSpecificationId,
    required this.reservedQuantity,
  });

  Map<String, dynamic> toJson() {
    return {'item_id': itemId, 'resourceSpecificationId': resourceSpecificationId, 'reserved_quantity': reservedQuantity};
  }
}
