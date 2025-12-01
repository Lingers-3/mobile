class TagFull {
  final int id;
  final int userId;
  final String name;
  final String? color;
  final List<int> itemIds;
  final List<int> itemTypeIds;

  TagFull({
    required this.id,
    required this.userId,
    required this.name,
    this.color,
    required this.itemIds,
    required this.itemTypeIds,
  });

  factory TagFull.fromJson(Map<String, dynamic> json) {
    return TagFull(
      id: json['id'],
      userId: json['user_id'],
      name: json['name'],
      color: json['color'],
      itemIds: List<int>.from(json['item_ids'] ?? []),
      itemTypeIds: List<int>.from(json['item_type_ids'] ?? []),
    );
  }
}
