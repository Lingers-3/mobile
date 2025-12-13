class ProjectUpdateActualRequest {
  final DateTime? actualDeadline;
  final double? actualIncome;
  final String currency;
  final double? actualWorkTime;

  ProjectUpdateActualRequest({
    this.actualDeadline,
    this.actualIncome = 0.0,
    this.currency = 'UAH',
    this.actualWorkTime = 0.0,
  });

  Map<String, dynamic> toJson() {
    return {
      'actual_deadline': actualDeadline,
      'actual_income': actualIncome,
      'currency': currency,
      'actual_work_time': actualWorkTime,
    };
  }
}
