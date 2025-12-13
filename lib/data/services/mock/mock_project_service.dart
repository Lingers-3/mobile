import 'dart:math';
import 'package:pocketeer_mobile/data/models/projects/project.dart';
import 'package:pocketeer_mobile/data/models/projects/project_create_request.dart';
import 'package:pocketeer_mobile/data/models/projects/project_state.dart';
import 'package:pocketeer_mobile/data/models/projects/project_update_request.dart';

class MockProjectService {
  final List<Project> _mockProjects = [
    Project(
      id: 1,
      name: 'Website Redesign',
      description: 'Overhaul the company website with new branding.',
      state: ProjectState.inProgress,
      plannedIncome: 5000,
      currency: 'UAH',
      createdAt: DateTime.now().subtract(const Duration(days: 10)),
      updatedAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
    Project(
      id: 2,
      name: 'Mobile App Feature',
      description: 'Add dark mode to the application.',
      state: ProjectState.planned,
      plannedIncome: 3000,
      currency: 'USD',
      createdAt: DateTime.now().subtract(const Duration(days: 5)),
      updatedAt: DateTime.now(),
    ),
    Project(
      id: 3,
      name: 'Legacy System Migration',
      description: 'Migrate old database to the new cloud cluster.',
      state: ProjectState.completed,
      actualIncome: 8000,
      currency: 'EUR',
      createdAt: DateTime.now().subtract(const Duration(days: 30)),
      updatedAt: DateTime.now().subtract(const Duration(days: 5)),
    ),
  ];

  Future<void> _simulateDelay() async {
    await Future.delayed(const Duration(milliseconds: 800));
  }

  Future<List<Project>> getAllProjects() async {
    await _simulateDelay();
    return List.from(_mockProjects);
  }

  Future<Project> getProject(int id) async {
    await _simulateDelay();
    final project = _mockProjects.firstWhere(
      (p) => p.id == id,
      orElse: () => throw Exception('Project not found'),
    );
    return project;
  }

  Future<Project> createProject(ProjectCreateRequest request) async {
    await _simulateDelay();

    final newId = (_mockProjects.isEmpty)
        ? 1
        : _mockProjects.map((p) => p.id).reduce(max) + 1;

    final newProject = Project(
      id: newId,
      name: request.name,
      description: request.description,
      state: ProjectState.planned,
      plannedDeadline: request.plannedDeadline,
      plannedIncome: request.plannedIncome,
      currency: request.currency,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    _mockProjects.add(newProject);
    return newProject;
  }

  Future<Project> updateProject(int id, ProjectUpdateRequest request) async {
    await _simulateDelay();

    final index = _mockProjects.indexWhere((p) => p.id == id);
    if (index == -1) {
      throw Exception('Project not found');
    }

    final oldProject = _mockProjects[index];

    final updatedProject = oldProject.copyWith(
      name: request.name,
      description: request.description,
      status: request.state,
      plannedDeadline: request.plannedDeadline,
      actualDeadline: request.actualDeadline,
      plannedIncome: request.plannedIncome,
      actualIncome: request.actualIncome,
      plannedHours: request.plannedHours,
      actualHours: request.actualHours,
      endDate: request.endDate,
      startDate: request.startDate,
      updatedAt: DateTime.now(),
    );

    _mockProjects[index] = updatedProject;
    return updatedProject;
  }

  Future<void> deleteProject(int id) async {
    await _simulateDelay();
    _mockProjects.removeWhere((p) => p.id == id);
  }

  Future<Project> startProject(int id) async {
    await _simulateDelay();
    final index = _mockProjects.indexWhere((p) => p.id == id);
    if (index == -1) {
      throw Exception('Project not found');
    }

    final project = _mockProjects[index];

    if (project.state != ProjectState.planned) {
      throw Exception('Only planned projects can be started');
    }

    _mockProjects[index] = project.copyWith(
      status: ProjectState.inProgress,
      startDate: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    return _mockProjects[index];
  }

  Future<Project> finishProject(int id) async {
    await _simulateDelay();
    final index = _mockProjects.indexWhere((p) => p.id == id);
    if (index == -1) {
      throw Exception('Project not found');
    }

    final project = _mockProjects[index];

    _mockProjects[index] = project.copyWith(
      status: ProjectState.completed,
      endDate: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    return _mockProjects[index];
  }

  Future<Project> cancelProject(int id) async {
    await _simulateDelay();
    final index = _mockProjects.indexWhere((p) => p.id == id);
    if (index == -1) {
      throw Exception('Project not found');
    }

    final project = _mockProjects[index];

    _mockProjects[index] = project.copyWith(
      status: ProjectState.cancelled,
      endDate: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    return _mockProjects[index];
  }
}
