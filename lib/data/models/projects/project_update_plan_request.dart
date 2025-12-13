class ProjectUpdatePlanRequest {
  final DateTime? plannedDeadline;
  final double? plannedIncome;
  final String currency;
  final double? plannedWorkTime;

  ProjectUpdatePlanRequest({
    required this.plannedDeadline,
    required this.plannedIncome,
    this.currency = 'UAH',
    required this.plannedWorkTime,
  });

  Map<String, dynamic> toJson() {
    return {
      'planned_deadline': plannedDeadline,
      'planned_income': plannedIncome,
      'currency': currency,
      'planned_work_time': plannedWorkTime,
    };
  }
}
