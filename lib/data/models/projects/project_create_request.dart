class ProjectCreateRequest {
  final String name;
  final String? description;
  final DateTime? plannedDeadline;
  final double? plannedIncome;
  final String currency;
  final double? plannedWorkTime;

  ProjectCreateRequest({
    required this.name,
    this.description,
    this.plannedDeadline,
    this.plannedIncome = 0.0,
    this.currency = 'UAH',
    this.plannedWorkTime = 0.0,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'planned_deadline': plannedDeadline,
      'planned_income': plannedIncome,
      'currency': currency,
      'planned_work_time': plannedWorkTime,
    };
  }
}
