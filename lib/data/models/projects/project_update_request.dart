import 'package:pocketeer_mobile/data/models/projects/project.dart';
import 'package:pocketeer_mobile/data/models/projects/project_state.dart';

class ProjectUpdateRequest {
  final String name;
  final String? description;
  final ProjectState state;

  final DateTime? plannedDeadline;
  final DateTime? actualDeadline;
  final DateTime? startDate;
  final DateTime? endDate;

  final double? plannedIncome;
  final double? actualIncome;
  final String currency;

  final double? plannedHours;
  final double? actualHours;

  ProjectUpdateRequest({
    required this.name,
    required this.description,
    required this.state,
    required this.plannedDeadline,
    required this.actualDeadline,
    required this.startDate,
    required this.endDate,
    required this.plannedIncome,
    required this.actualIncome,
    required this.currency,
    required this.plannedHours,
    required this.actualHours,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'state': state.toJson(),
      'planned_deadline': plannedDeadline?.toIso8601String(),
      'actual_deadline': actualDeadline?.toIso8601String(),
      'start_date': startDate?.toIso8601String(),
      'end_date': endDate?.toIso8601String(),
      'planned_income': plannedIncome,
      'actual_income': actualIncome,
      'currency': currency,
      'planned_hours': plannedHours,
      'actual_hours': actualHours,
    };
  }

  static ProjectUpdateRequest fromProject(Project project) {
    return ProjectUpdateRequest(
      name: project.name,
      description: project.description,
      state: project.state,
      plannedDeadline: project.plannedDeadline,
      actualDeadline: project.actualDeadline,
      startDate: project.startDate,
      endDate: project.endDate,
      plannedIncome: project.plannedIncome,
      actualIncome: project.actualIncome,
      currency: project.currency,
      plannedHours: project.plannedHours,
      actualHours: project.actualHours,
    );
  }
}
