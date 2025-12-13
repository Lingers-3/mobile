enum ProjectStatus {
  planned,
  inProgress,
  completed,
  cancelled;

  String get label {
    switch (this) {
      case ProjectStatus.planned:
        return 'Заплановано';
      case ProjectStatus.inProgress:
        return 'В процесі';
      case ProjectStatus.completed:
        return 'Завершено';
      case ProjectStatus.cancelled:
        return 'Відмінено';
    }
  }
}

class Project {
  final int id;
  final String name;
  final String? description;
  final ProjectStatus status;

  // Дати
  final DateTime? plannedDeadline;
  final DateTime? actualDeadline;
  final DateTime? startDate;
  final DateTime? endDate;

  // Фінанси
  final double? plannedIncome;
  final double? actualIncome;
  final String currency;

  // Години
  final double? plannedHours;
  final double? actualHours;

  final DateTime createdAt;
  final DateTime updatedAt;

  Project({
    required this.id,
    required this.name,
    required this.description,
    required this.status,
    this.plannedDeadline,
    this.actualDeadline,
    this.startDate,
    this.endDate,
    this.plannedIncome,
    this.actualIncome,
    this.currency = 'UAH',
    this.plannedHours,
    this.actualHours,
    required this.createdAt,
    required this.updatedAt,
  });

  Project copyWith({
    int? id,
    String? name,
    String? description,
    ProjectStatus? status,
    DateTime? plannedDeadline,
    DateTime? actualDeadline,
    DateTime? startDate,
    DateTime? endDate,
    double? plannedIncome,
    double? actualIncome,
    String? currency,
    double? plannedHours,
    double? actualHours,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Project(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      status: status ?? this.status,
      plannedDeadline: plannedDeadline ?? this.plannedDeadline,
      actualDeadline: actualDeadline ?? this.actualDeadline,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      plannedIncome: plannedIncome ?? this.plannedIncome,
      actualIncome: actualIncome ?? this.actualIncome,
      currency: currency ?? this.currency,
      plannedHours: plannedHours ?? this.plannedHours,
      actualHours: actualHours ?? this.actualHours,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
