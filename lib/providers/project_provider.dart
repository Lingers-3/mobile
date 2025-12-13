import 'package:flutter/material.dart';
import 'package:pocketeer_mobile/data/models/projects/project.dart';
import 'package:pocketeer_mobile/data/models/projects/project_create_request.dart';
import 'package:pocketeer_mobile/data/models/projects/project_update_actual_request.dart';
import 'package:pocketeer_mobile/data/models/projects/project_update_plan_request.dart';
import 'package:pocketeer_mobile/data/models/projects/project_update_request.dart';
import 'package:pocketeer_mobile/data/services/project_service.dart';

class ProjectProvider extends ChangeNotifier {
  final ProjectService _projectService = ProjectService();

  List<Project> _projects = [];
  bool _isLoading = false;
  String? _error;

  List<Project> get projects => _projects;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchProjects() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _projects = await _projectService.getAllProjects();
    } catch (e) {
      _error = e.toString();
      _projects = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Project> createProject(String name) async {
    _isLoading = true;
    notifyListeners();

    try {
      final request = ProjectCreateRequest(name: name);
      final newProject = await _projectService.createProject(request);
      _projects.add(newProject);
      return newProject;
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateProjectPlan(
    int id,
    DateTime? plannedDeadline,
    double? plannedIncome,
    double? plannedWorkTime,
  ) async {
    _isLoading = true;
    notifyListeners();

    try {
      final index = _projects.indexWhere((p) => p.id == id);
      if (index != -1) {
        final request = ProjectUpdatePlanRequest(
          plannedDeadline: plannedDeadline,
          plannedIncome: plannedIncome,
          plannedWorkTime: plannedWorkTime,
        );
        final result = await _projectService.updateProjectPlan(id, request);
        _projects[index] = result;
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateProjectActual(
    int id,
    DateTime? actualDeadline,
    double? actualIncome,
    double? actualWorkTime,
  ) async {
    _isLoading = true;
    notifyListeners();

    try {
      final index = _projects.indexWhere((p) => p.id == id);
      if (index != -1) {
        final request = ProjectUpdateActualRequest(
          actualDeadline: actualDeadline,
          actualIncome: actualIncome,
          actualWorkTime: actualWorkTime,
        );
        final result = await _projectService.updateProjectActual(id, request);
        _projects[index] = result;
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateProjectInfo(
    int id,
    String name,
    String? description,
  ) async {
    _isLoading = true;
    notifyListeners();

    try {
      final index = _projects.indexWhere((p) => p.id == id);
      if (index != -1) {
        final request = ProjectUpdateRequest(
          name: name,
          description: description,
        );
        final result = await _projectService.updateProjectInfo(id, request);
        _projects[index] = result;
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteProject(int id) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _projectService.deleteProject(id);
      _projects.removeWhere((p) => p.id == id);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // NOTE(saloway): may require to fetch resource reservations afterwards
  Future<void> startProject(int id) async {
    try {
      final result = await _projectService.startProject(id);

      final index = _projects.indexWhere((p) => p.id == id);
      if (index != -1) {
        _projects[index] = result;
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // NOTE(saloway): may require to fetch items afterwards
  Future<void> finishProject(int id) async {
    try {
      final result = await _projectService.finishProject(id);

      final index = _projects.indexWhere((p) => p.id == id);
      if (index != -1) {
        _projects[index] = result;
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // NOTE(saloway): may require to fetch resource reservations afterwards
  Future<void> cancelProject(int id) async {
    try {
      final result = await _projectService.cancelProject(id);

      final index = _projects.indexWhere((p) => p.id == id);
      if (index != -1) {
        _projects[index] = result;
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
