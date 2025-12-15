import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:pocketeer_mobile/data/models/projects/project.dart';
import 'package:pocketeer_mobile/data/models/projects/project_requests.dart';
import 'package:pocketeer_mobile/data/models/resource_specifications/resource_type.dart';
import 'package:pocketeer_mobile/data/services/project_service.dart';

class ProjectProvider extends ChangeNotifier {
  final ProjectService _projectService = ProjectService();

  Map<int, Project> _projectsById = {};
  bool _isLoading = false;
  String? _error;

  List<Project> get projects => _projectsById.values.toList();
  bool get isLoading => _isLoading;
  String? get error => _error;
  Project? getById(int id) => _projectsById[id];
  Map<int, Project> get projectsById => UnmodifiableMapView(_projectsById);

  Future<void> fetchProjects() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final projects = await _projectService.getAllProjects();
      _projectsById = _projectsById = {for (final p in projects) p.id: p};
    } catch (e) {
      _error = e.toString();
      _projectsById = {};
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchProject(int id, {bool force = false}) async {
    if (!force && _projectsById.containsKey(id)) {
      return;
    }

    _isLoading = true;
    notifyListeners();

    try {
      final project = await _projectService.getProject(id);
      _upsertProject(project);
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
      _projectsById[newProject.id] = newProject;
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
    int? plannedWorkTime,
  ) async {
    _isLoading = true;
    notifyListeners();

    try {
      final request = ProjectUpdatePlanRequest(
        plannedDeadline: plannedDeadline,
        plannedIncome: plannedIncome,
        plannedWorkTime: plannedWorkTime,
      );
      await _projectService.updateProjectPlan(id, request);
      await fetchProject(id, force: true);
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
    int? actualWorkTime,
  ) async {
    _isLoading = true;
    notifyListeners();

    try {
      final request = ProjectUpdateActualRequest(
        actualDeadline: actualDeadline,
        actualIncome: actualIncome,
        actualWorkTime: actualWorkTime,
      );
      await _projectService.updateProjectActual(id, request);
      await fetchProject(id, force: true);
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
      final request = ProjectUpdateRequest(
        name: name,
        description: description,
      );
      await _projectService.updateProjectInfo(id, request);
      await fetchProject(id, force: true);
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
      _projectsById.remove(id);
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
    ResourceType resourceType,
    double plannedQuantity,
  ) async {
    _isLoading = true;
    notifyListeners();

    try {
      final request = ProjectPlanResourceRequest(
        itemTypeId: itemTypeId,
        plannedQuantity: plannedQuantity,
        resourceType: resourceType,
      );
      await _projectService.planResource(projectId, request);
      await fetchProject(projectId, force: true);
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
      await fetchProject(projectId, force: true);
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
    double plannedQuantity,
  ) async {
    _isLoading = true;
    notifyListeners();

    try {
      final request = ProjectAddResourceSpecificationRequest(
        itemTypeId: itemTypeId,
        resourceType: resourceType,
        plannedQuantity: plannedQuantity,
      );
      await _projectService.addResourceSpecification(projectId, request);
      await fetchProject(projectId, force: true);
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
      await fetchProject(projectId, force: true);
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
      await _projectService.reserveItem(
        projectId,
        resourceSpecificationId,
        request,
      );
      await fetchProject(projectId, force: true);
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
      await fetchProject(projectId, force: true);
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
      await _projectService.startProject(id);
      await fetchProject(id, force: true);
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
      await _projectService.finishProject(id);
      await fetchProject(id, force: true);
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
      await _projectService.cancelProject(id);
      await fetchProject(id, force: true);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void _upsertProject(Project project) {
    _projectsById[project.id] = project;
  }
}
