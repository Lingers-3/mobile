import 'package:flutter/material.dart';
import 'package:pocketeer_mobile/data/models/projects/project.dart';

class ProjectProvider extends ChangeNotifier {
  // MOCK DATA: Один проект для демонстрації
  Project _activeProject = Project(
    id: 1,
    name: "Будка для собаки",
    description:
        "Будівництво утепленої будки для великої собаки. "
        "Потрібно використати залишки матеріалів з гаража та докупити утеплювач. "
        "Конструкція має бути розбірна для зручного чищення.",
    status: ProjectStatus.inProgress,
    plannedDeadline: DateTime.now().add(const Duration(days: 7)),
    plannedIncome: 0.0, // Особистий проект
    plannedHours: 10.0,
    actualHours: 2.5,
    currency: 'UAH',
    startDate: DateTime.now().subtract(const Duration(days: 2)),
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
  );

  Project get project => _activeProject;

  void updateProject(Project updatedProject) {
    _activeProject = updatedProject;
    notifyListeners();
  }
}
