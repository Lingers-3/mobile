class Tag {
  final int id;
  final String name;
  final String? color;

  const Tag({required this.id, required this.name, this.color});

  factory Tag.fromJson(Map<String, dynamic> json) {
    return Tag(id: json['id'], name: json['name'], color: json['color']);
  }
}
