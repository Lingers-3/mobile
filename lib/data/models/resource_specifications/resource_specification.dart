enum ResourceType {
  tool, // Інструмент (не витрачається)
  material, // Матеріал (витрачається)
}

class ResourceSpecification {
  final int id;
  final int projectId;
  final int itemTypeId; // Посилання на тип предмету
  final ResourceType resourceType;
  final double plannedQuantity;

  // Додаткові поля для аудиту
  final DateTime createdAt;
  final DateTime updatedAt;

  ResourceSpecification({
    required this.id,
    required this.projectId,
    required this.itemTypeId,
    required this.resourceType,
    this.plannedQuantity = 0.0,
    required this.createdAt,
    required this.updatedAt,
  });

  // Метод для відображення типу українською
  String get resourceTypeLabel {
    switch (resourceType) {
      case ResourceType.tool:
        return 'Інструмент';
      case ResourceType.material:
        return 'Матеріал';
    }
  }
}
