import 'package:pocketeer_mobile/data/models/projects/project_state.dart';
import 'package:pocketeer_mobile/data/models/resource_specifications/resource_specification.dart';

class _Sentinel {
  const _Sentinel();
}

const _undefined = _Sentinel();

class Project {
  final int id;
  final String name;
  final String? description;
  final ProjectState state;

  final DateTime? plannedDeadline;
  final DateTime? actualDeadline;
  final DateTime? startDate;
  final DateTime? endDate;

  final double? plannedIncome;
  final double? actualRevenue;
  final String currency;

  final int? plannedWorkTime;
  final int? actualWorkTime;

  final DateTime createdAt;
  final DateTime updatedAt;

  final List<ResourceSpecification>? specifications;

  Project({
    required this.id,
    required this.name,
    required this.description,
    required this.state,
    this.plannedDeadline,
    this.actualDeadline,
    this.startDate,
    this.endDate,
    this.plannedIncome,
    this.actualRevenue,
    this.currency = 'UAH',
    this.plannedWorkTime,
    this.actualWorkTime,
    required this.createdAt,
    required this.updatedAt,
    this.specifications,
  });

  Project copyWith({
    int? id,
    String? name,
    // Using Object? for nullable fields to distinguish between "ignore" and "set to null"
    Object? description = _undefined,
    ProjectState? state,
    Object? plannedDeadline = _undefined,
    Object? actualDeadline = _undefined,
    Object? startDate = _undefined,
    Object? endDate = _undefined,
    Object? plannedIncome = _undefined,
    Object? actualRevenue = _undefined,
    String? currency,
    Object? plannedWorkTime = _undefined,
    Object? actualWorkTime = _undefined,
    DateTime? createdAt,
    DateTime? updatedAt,
    Object? specifications =
        _undefined, // Added support for updating specifications
  }) {
    return Project(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description == _undefined
          ? this.description
          : description as String?,
      state: state ?? this.state,
      plannedDeadline: plannedDeadline == _undefined
          ? this.plannedDeadline
          : plannedDeadline as DateTime?,
      actualDeadline: actualDeadline == _undefined
          ? this.actualDeadline
          : actualDeadline as DateTime?,
      startDate: startDate == _undefined
          ? this.startDate
          : startDate as DateTime?,
      endDate: endDate == _undefined ? this.endDate : endDate as DateTime?,
      plannedIncome: plannedIncome == _undefined
          ? this.plannedIncome
          : plannedIncome as double?,
      actualRevenue: actualRevenue == _undefined
          ? this.actualRevenue
          : actualRevenue as double?,
      currency: currency ?? this.currency,
      plannedWorkTime: plannedWorkTime == _undefined
          ? this.plannedWorkTime
          : plannedWorkTime as int?,
      actualWorkTime: actualWorkTime == _undefined
          ? this.actualWorkTime
          : actualWorkTime as int?,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      specifications: specifications == _undefined
          ? this.specifications
          : specifications as List<ResourceSpecification>?,
    );
  }

  factory Project.fromJson(Map<String, dynamic> json) {
    return Project(
      id: json['id'] as int,
      name: json['name'] as String,
      description: json['description'] as String?,
      state: ProjectState.fromJson(json['state'] as String),
      plannedDeadline: json['planned_deadline'] != null
          ? DateTime.parse(json['planned_deadline'])
          : null,
      actualDeadline: json['actual_deadline'] != null
          ? DateTime.parse(json['actual_deadline'])
          : null,
      startDate: json['start_date'] != null
          ? DateTime.parse(json['start_date'])
          : null,
      endDate: json['end_date'] != null
          ? DateTime.parse(json['end_date'])
          : null,
      plannedIncome: (json['planned_income'] as num?)?.toDouble(),
      actualRevenue: (json['actual_income'] as num?)?.toDouble(),
      currency: json['currency'] as String? ?? 'UAH',
      plannedWorkTime: (json['planned_work_time'] as num?)?.toInt(),
      actualWorkTime: (json['actual_work_time'] as num?)?.toInt(),
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      specifications: json['specifications'] != null
          ? (json['specifications'] as List)
                .map((e) => ResourceSpecification.fromJson(e))
                .toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'state': state.toJson(),
      'planned_deadline': plannedDeadline?.toUtc().toIso8601String(),
      'actual_deadline': actualDeadline?.toUtc().toIso8601String(),
      'start_date': startDate?.toUtc().toIso8601String(),
      'end_date': endDate?.toUtc().toIso8601String(),
      'planned_income': plannedIncome,
      'actual_income': actualRevenue,
      'currency': currency,
      'planned_work_time': plannedWorkTime,
      'actual_work_time': actualWorkTime,
      'created_at': createdAt.toUtc().toIso8601String(),
      'updated_at': updatedAt.toUtc().toIso8601String(),
      'specifications': specifications?.map((e) => e.toJson()).toList(),
    };
  }
}
