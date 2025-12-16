class ItemType {
  final int id;
  final String name;
  final String? description;
  final String baseMeasurementUnit;
  final String displayMeasurementUnit;
  final double? defaultQuantity;
  final double? shortageThreshold;
  final int? pictureId;
  final List<int> itemIds;
  final List<int> tagIds;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;

  double totalQuantity;

  ItemType({
    required this.id,
    required this.name,
    this.description,
    required this.baseMeasurementUnit,
    required this.displayMeasurementUnit,
    this.defaultQuantity,
    this.shortageThreshold,
    this.pictureId,
    required this.itemIds,
    required this.tagIds,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    this.totalQuantity = 0,
  });

  factory ItemType.fromJson(Map<String, dynamic> json) {
    return ItemType(
      id: json['id'] as int,
      name: json['name'] as String,
      description: json['description'] as String?,
      baseMeasurementUnit: json['base_measurement_unit'] as String,
      displayMeasurementUnit: json['display_measurement_unit'] as String,
      defaultQuantity: (json['default_quantity'] as num?)?.toDouble(),
      shortageThreshold: (json['shortage_threshold'] as num?)?.toDouble(),
      pictureId: json['picture_id'] as int?,
      itemIds: (json['item_ids'] as List<dynamic>? ?? const [])
          .map((e) => e as int)
          .toList(),
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
      'name': name,
      'description': description,
      'base_measurement_unit': baseMeasurementUnit,
      'display_measurement_unit': displayMeasurementUnit,
      'default_quantity': defaultQuantity,
      'shortage_threshold': shortageThreshold,
      'picture_id': pictureId,
      'item_ids': itemIds,
      'tag_ids': tagIds,
      'created_at': createdAt.toUtc().toIso8601String(),
      'updated_at': updatedAt.toUtc().toIso8601String(),
      'deleted_at': deletedAt?.toUtc().toIso8601String(),
    };
  }
}
