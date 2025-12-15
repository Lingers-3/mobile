class Item {
  final int id;
  final String? description;
  final double quantity;
  final DateTime? expirationDate;
  final String displayMeasurementUnit;
  final double? purchasePrice;
  final int itemTypeId;
  final List<int> tagIds;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;

  Item({
    required this.id,
    this.description,
    required this.quantity,
    this.expirationDate,
    required this.displayMeasurementUnit,
    this.purchasePrice,
    required this.itemTypeId,
    required this.tagIds,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });

  factory Item.fromJson(Map<String, dynamic> json) {
    return Item(
      id: json['id'] as int,
      description: json['description'] as String?,
      quantity: (json['quantity'] as num).toDouble(),
      expirationDate: json['expiration_date'] != null
          ? DateTime.parse(json['expiration_date'] as String)
          : null,
      displayMeasurementUnit: json['display_measurement_unit'] as String,
      purchasePrice: (json['purchase_price'] as num?)?.toDouble(),
      itemTypeId: json['item_type_id'] as int,
      tagIds: (json['tag_ids'] as List<dynamic>? ?? const [])
          .map((e) => e as int)
          .toList(),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      deletedAt: json['deleted_at'] != null
          ? DateTime.parse(json['deleted_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'description': description,
      'quantity': quantity,
      'expiration_date': expirationDate?.toUtc().toIso8601String(),
      'display_measurement_unit': displayMeasurementUnit,
      'purchase_price': purchasePrice,
      'item_type_id': itemTypeId,
      'tag_ids': tagIds,
      'created_at': createdAt.toUtc().toIso8601String(),
      'updated_at': updatedAt.toUtc().toIso8601String(),
      'deleted_at': deletedAt?.toUtc().toIso8601String(),
    };
  }
}
