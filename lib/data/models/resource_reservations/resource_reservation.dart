class ResourceReservation {
  final int id;
  final int itemId;
  final double reservedQuantity;
  final double usedQuantity;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;

  ResourceReservation({
    required this.id,
    required this.itemId,
    required this.reservedQuantity,
    this.usedQuantity = 0.0,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });

  factory ResourceReservation.fromJson(Map<String, dynamic> json) {
    return ResourceReservation(
      id: json['id'] as int,
      itemId: json['item_id'] as int,
      reservedQuantity: (json['reserved_quantity'] as num).toDouble(),
      usedQuantity: (json['used_quantity'] as num? ?? 0.0).toDouble(),
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
      'item_id': itemId,
      'reserved_quantity': reservedQuantity,
      'used_quantity': usedQuantity,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'deleted_at': deletedAt?.toIso8601String(),
    };
  }
}