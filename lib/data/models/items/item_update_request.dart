class ItemUpdateRequest {
  final String? description;
  final double? quantity;
  final DateTime? expirationDate;
  final String? displayMeasurementUnit;
  final double? purchasePrice;
  final List<int>? tagIds;

  ItemUpdateRequest({
    this.description,
    this.quantity,
    this.expirationDate,
    this.displayMeasurementUnit,
    this.purchasePrice,
    this.tagIds,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};

    if (description != null) data['description'] = description;
    if (quantity != null) data['quantity'] = quantity;
    if (expirationDate != null) {
      data['expiration_date'] = expirationDate!
          .toUtc()
          .toUtc()
          .toIso8601String();
    }
    if (displayMeasurementUnit != null) {
      data['display_measurement_unit'] = displayMeasurementUnit;
    }
    if (purchasePrice != null) {
      data['purchase_price'] = purchasePrice;
    }
    if (tagIds != null) {
      data['tag_ids'] = tagIds;
    }

    return data;
  }
}
