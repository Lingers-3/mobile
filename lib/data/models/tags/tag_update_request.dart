class TagUpdateRequest {
  final String? name;
  final String? color;

  TagUpdateRequest({this.name, this.color});

  Map<String, dynamic> toJson() => {
    if (name != null) "name": name,
    if (color != null) "color": color,
  };
}
