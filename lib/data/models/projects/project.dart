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
  final String description;
  final ProjectStatus status;

  // Дати
  final DateTime? plannedDeadline; // Опціонально
  final DateTime? actualDeadline; // "Перенесений" або "Фактичний" дедлайн
  final DateTime? startDate;
  final DateTime? endDate;

  // Фінанси
  final double? plannedIncome; // Опціонально (тепер nullable)
  final double
  actualIncome; // Фактичний дохід зазвичай починається з 0, тому лишаємо double
  final String currency;

  // Години
  final double? plannedHours; // Опціонально (тепер nullable)
  final double actualHours;

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
    this.plannedIncome, // null за замовчуванням
    this.actualIncome = 0.0,
    this.currency = 'UAH',
    this.plannedHours, // null за замовчуванням
    this.actualHours = 0.0,
    required this.createdAt,
    required this.updatedAt,
  });

  // copyWith ... (оновіть відповідні поля на nullable, якщо використовуєте)
}
