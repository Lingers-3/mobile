class ItemCreateRequest {
  final int itemTypeId;
  final String? description;
  final double? quantity;
  final DateTime? expirationDate;
  final String? displayMeasurementUnit;
  final double? purchasePrice;
  final List<int> tagIds;

  ItemCreateRequest({
    required this.itemTypeId,
    this.description,
    this.quantity,
    this.expirationDate,
    this.displayMeasurementUnit,
    this.purchasePrice,
    this.tagIds = const [],
  });

  Map<String, dynamic> toJson() {
    return {
      'item_type_id': itemTypeId,
      'description': description,
      'quantity': quantity,
      'expiration_date': expirationDate?.toUtc().toUtc().toIso8601String(),
      'display_measurement_unit': displayMeasurementUnit,
      'purchase_price': purchasePrice,
      'tag_ids': tagIds,
    };
  }
}
