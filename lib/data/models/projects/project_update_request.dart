class ProjectUpdateRequest {
  final String name;
  final String? description;

  ProjectUpdateRequest({required this.name, required this.description});

  Map<String, dynamic> toJson() {
    return {'name': name, 'description': description};
  }
}
