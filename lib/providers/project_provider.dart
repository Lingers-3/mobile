import 'package:flutter/material.dart';
import 'package:pocketeer_mobile/data/models/projects/project.dart';
import 'package:pocketeer_mobile/data/models/projects/project_requests.dart';
import 'package:pocketeer_mobile/data/models/resource_specifications/resource_type.dart';
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

  Future<void> getProject(int id) async {
    _isLoading = true;
    notifyListeners();

    try {
      final project = await _projectService.getProject(id);
      _updateLocalProject(project);
    } catch (e) {
      _error = e.toString();
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

  Future<void> planResource(
    int projectId,
    int itemTypeId,
    double plannedQuantity,
    ResourceType resourceType,
  ) async {
    _isLoading = true;
    notifyListeners();

    try {
      final request = ProjectPlanResourceRequest(
        itemTypeId: itemTypeId,
        plannedQuantity: plannedQuantity,
        resourceType: resourceType,
      );
      final result = await _projectService.planResource(projectId, request);
      _updateLocalProject(result);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> unplanResource(
    int projectId,
    int plannedResourceSpecificationId,
  ) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _projectService.unplanResource(
        projectId,
        plannedResourceSpecificationId,
      );
      await getProject(projectId);
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addResourceSpecification(
    int projectId,
    int itemTypeId,
    ResourceType resourceType,
  ) async {
    _isLoading = true;
    notifyListeners();

    try {
      final request = ProjectAddResourceSpecificationRequest(
        itemTypeId: itemTypeId,
        resourceType: resourceType,
      );
      final result = await _projectService.addResourceSpecification(
        projectId,
        request,
      );
      _updateLocalProject(result);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> removeResourceSpecification(
    int projectId,
    int resourceSpecificationId,
  ) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _projectService.removeResourceSpecification(
        projectId,
        resourceSpecificationId,
      );
      await getProject(projectId);
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> reserveItem(
    int projectId,
    int resourceSpecificationId,
    int itemId,
    double reservedQuantity,
    double usedQuantity,
  ) async {
    _isLoading = true;
    notifyListeners();

    try {
      final request = ProjectAddResourceReservationRequest(
        itemId: itemId,
        reservedQuantity: reservedQuantity,
        usedQuantity: usedQuantity,
      );
      final result = await _projectService.reserveItem(
        projectId,
        resourceSpecificationId,
        request,
      );
      _updateLocalProject(result);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> freeItem(
    int projectId,
    int resourceSpecificationId,
    int resourceReservationId,
  ) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _projectService.freeItem(
        projectId,
        resourceSpecificationId,
        resourceReservationId,
      );
      await getProject(projectId);
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> startProject(int id) async {
    _isLoading = true;
    notifyListeners();

    try {
      final result = await _projectService.startProject(id);
      _updateLocalProject(result);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> finishProject(int id) async {
    _isLoading = true;
    notifyListeners();

    try {
      final result = await _projectService.finishProject(id);
      _updateLocalProject(result);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> cancelProject(int id) async {
    _isLoading = true;
    notifyListeners();

    try {
      final result = await _projectService.cancelProject(id);
      _updateLocalProject(result);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void _updateLocalProject(Project project) {
    final index = _projects.indexWhere((p) => p.id == project.id);
    if (index != -1) {
      _projects[index] = project;
    }
  }
}
