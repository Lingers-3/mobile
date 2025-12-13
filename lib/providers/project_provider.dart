import 'dart:math';
import 'package:flutter/material.dart';
import 'package:pocketeer_mobile/data/models/projects/project.dart';

class ProjectProvider extends ChangeNotifier {
  // MOCK DATA: Список проектів
  final List<Project> _projects = [
    Project(
      id: 1,
      name: "Будка для собаки",
      description: "Будівництво утепленої будки...",
      status: ProjectStatus.inProgress,
      plannedDeadline: DateTime.now().add(const Duration(days: 7)),
      actualDeadline: DateTime.now().add(
        const Duration(days: 3),
      ), // Зміщений термін
      plannedIncome: null,
      plannedHours: 10.0,
      actualHours: 2.5,
      currency: 'UAH',
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
      updatedAt: DateTime.now(),
      startDate: DateTime.now().subtract(const Duration(days: 2)),
    ),
    Project(
      id: 2,
      name: "Ремонт кухні",
      description: "Косметичний ремонт: фарбування стін, заміна плінтусів.",
      status: ProjectStatus.planned,
      plannedDeadline: DateTime.now().add(const Duration(days: 30)),
      plannedIncome: 15000.0,
      plannedHours: 40.0,
      actualHours: null,
      currency: 'UAH',
      createdAt: DateTime.now().subtract(const Duration(days: 5)),
      updatedAt: DateTime.now(),
    ),
    Project(
      id: 3,
      name: "Аніме це сила!!!",
      description: "Ня.",
      status: ProjectStatus.cancelled,
      plannedDeadline: DateTime.now().add(const Duration(days: 30)),
      plannedIncome: 10000.0,
      plannedHours: null,
      actualHours: null,
      currency: 'UAH',
      createdAt: DateTime.now().subtract(const Duration(days: 5)),
      updatedAt: DateTime.now().subtract(const Duration(days: 1)),
      endDate: DateTime.now().subtract(const Duration(days: 1)),
    ),
    Project(
      id: 4,
      name: "Bruh",
      description: "Bruh.",
      status: ProjectStatus.completed,
      plannedDeadline: DateTime.now().add(const Duration(days: 30)),
      plannedIncome: 10000.0,
      plannedHours: null,
      actualHours: null,
      currency: 'UAH',
      createdAt: DateTime.now().subtract(const Duration(days: 5)),
      updatedAt: DateTime.now().subtract(const Duration(days: 1)),
      endDate: DateTime.now().subtract(const Duration(days: 1)),
    ),
  ];

  List<Project> get projects => _projects;

  // Створення нового проекту (тільки назва)
  Project createProject(String name) {
    final newId = _projects.isNotEmpty
        ? _projects.map((e) => e.id).reduce(max) + 1
        : 1;

    final newProject = Project(
      id: newId,
      name: name,
      description: "", // Порожній опис за замовчуванням
      status: ProjectStatus.planned, // Початковий статус
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      // Всі інші поля за замовчуванням null або 0.0, як визначено в моделі
    );

    _projects.add(newProject);
    notifyListeners();

    return newProject;
  }

  // Оновлення проекту (на майбутнє)
  void updateProject(Project updatedProject) {
    final index = _projects.indexWhere((p) => p.id == updatedProject.id);
    if (index != -1) {
      _projects[index] = updatedProject;
      notifyListeners();
    }
  }
}
