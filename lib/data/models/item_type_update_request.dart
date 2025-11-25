class ItemTypeUpdateRequest {
  final String? name;
  final String? description;
  final String? baseMeasurementUnit;
  final String? displayMeasurementUnit;
  final double? defaultQuantity;
  final double? shortageThreshold;
  final int? pictureId;
  final List<int>? tagIds;
  final bool? restore;

  ItemTypeUpdateRequest({
    this.name,
    this.description,
    this.baseMeasurementUnit,
    this.displayMeasurementUnit,
    this.defaultQuantity,
    this.shortageThreshold,
    this.pictureId,
    this.tagIds,
    this.restore,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};

    if (name != null) data['name'] = name;
    if (description != null) data['description'] = description;
    if (baseMeasurementUnit != null) {
      data['base_measurement_unit'] = baseMeasurementUnit;
    }
    if (displayMeasurementUnit != null) {
      data['display_measurement_unit'] = displayMeasurementUnit;
    }
    if (defaultQuantity != null) {
      data['default_quantity'] = defaultQuantity;
    }
    if (shortageThreshold != null) {
      data['shortage_threshold'] = shortageThreshold;
    }
    if (pictureId != null) {
      data['picture_id'] = pictureId;
    }
    if (tagIds != null) {
      data['tag_ids'] = tagIds;
    }
    if (restore != null) {
      data['restore'] = restore;
    }

    return data;
  }
}
