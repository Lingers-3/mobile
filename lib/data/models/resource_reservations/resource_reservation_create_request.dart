class ResourceReservationCreateRequest {
  final int itemId;
  final double reservedQuantity;

  ResourceReservationCreateRequest({
    required this.itemId,
    required this.reservedQuantity,
  });

  Map<String, dynamic> toJson() {
    return {'item_id': itemId, 'reserved_quantity': reservedQuantity};
  }
}
