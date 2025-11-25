class ItemTypeCreateRequest {
  final String name;
  final String? description;
  final String baseMeasurementUnit;
  final String displayMeasurementUnit;
  final double? defaultQuantity;
  final double? shortageThreshold;
  final int? pictureId;
  final List<int> tagIds;

  ItemTypeCreateRequest({
    required this.name,
    this.description,
    required this.baseMeasurementUnit,
    required this.displayMeasurementUnit,
    this.defaultQuantity,
    this.shortageThreshold,
    this.pictureId,
    this.tagIds = const [],
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'base_measurement_unit': baseMeasurementUnit,
      'display_measurement_unit': displayMeasurementUnit,
      'default_quantity': defaultQuantity,
      'shortage_threshold': shortageThreshold,
      'picture_id': pictureId,
      'tag_ids': tagIds,
    };
  }
}
