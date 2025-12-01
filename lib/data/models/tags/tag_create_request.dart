class TagCreateRequest {
  final String name;
  final String? color;

  final String? targetType;

  final int? targetId;

  TagCreateRequest({
    required this.name,
    this.color,
    this.targetType,
    this.targetId,
  });

  Map<String, dynamic> toJson() => {
    "name": name,
    "color": color,
    "target_type": targetType,
    "target_id": targetId,
  };
}

