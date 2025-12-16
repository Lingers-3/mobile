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
    final request = ProjectUpdatePlanRequest(
      plannedDeadline: plannedDeadline,
      plannedIncome: plannedIncome,
      plannedWorkTime: plannedWorkTime,
    );

    _isLoading = true;
    notifyListeners();

    try {
      final partialUpdatedProject = await _projectService.updateProjectPlan(
        id,
        request,
      );
      final oldProject = _projectsById[id];
      if (oldProject == null) return;
      final mergedProject = oldProject.copyWith(
        plannedDeadline: partialUpdatedProject.plannedDeadline,
        plannedIncome: partialUpdatedProject.plannedIncome,
        plannedWorkTime: partialUpdatedProject.plannedWorkTime,
      );
      _projectsById[id] = mergedProject;
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
      final partialUpdatedProject = await _projectService.updateProjectActual(
        id,
        request,
      );
      final oldProject = _projectsById[id];
      if (oldProject == null) return;
      final mergedProject = oldProject.copyWith(
        actualDeadline: partialUpdatedProject.actualDeadline,
        actualRevenue: partialUpdatedProject.actualRevenue,
        actualWorkTime: partialUpdatedProject.actualWorkTime,
      );
      _projectsById[id] = mergedProject;
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
      final partialUpdatedProject = await _projectService.updateProjectInfo(
        id,
        request,
      );
      final oldProject = _projectsById[id];
      if (oldProject == null) return;
      final mergedProject = oldProject.copyWith(
        name: partialUpdatedProject.name,
        description: partialUpdatedProject.description,
      );
      _projectsById[id] = mergedProject;
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
      final newSpec = await _projectService.planResource(projectId, request);
      final oldProject = _projectsById[projectId];
      if (oldProject == null) return;
      final currentSpecs = oldProject.specifications ?? [];
      final updatedSpecs = [...currentSpecs, newSpec];
      final updatedProject = oldProject.copyWith(specifications: updatedSpecs);
      _projectsById[projectId] = updatedProject;
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
      final oldProject = _projectsById[projectId];
      if (oldProject == null) return;
      final currentSpecs = oldProject.specifications ?? [];
      final updatedSpecs = currentSpecs
          .where((s) => s.id != plannedResourceSpecificationId)
          .toList();
      final updatedProject = oldProject.copyWith(specifications: updatedSpecs);
      _projectsById[projectId] = updatedProject;
    } catch (e) {
      _error = e.toString();
    } finally {
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
      final newProject = await _projectService.addResourceSpecification(
        projectId,
        request,
      );
      _projectsById[projectId] = newProject;
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
      final oldProject = _projectsById[projectId];
      if (oldProject == null) return;
      final currentSpecs = oldProject.specifications ?? [];
      final updatedSpecs = currentSpecs
          .where((s) => s.id != resourceSpecificationId)
          .toList();
      final updatedProject = oldProject.copyWith(specifications: updatedSpecs);
      _projectsById[projectId] = updatedProject;
    } catch (e) {
      _error = e.toString();
    } finally {
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
      final newReservation = await _projectService.reserveItem(
        projectId,
        resourceSpecificationId,
        request,
      );
      final oldProject = _projectsById[projectId];
      if (oldProject == null) return;
      final updatedSpecs = oldProject.specifications?.map((spec) {
        if (spec.id == resourceSpecificationId) {
          final updatedReservations = [...?spec.reservations, newReservation];
          return spec.copyWith(reservations: updatedReservations);
        }
        return spec;
      }).toList();
      final updatedProject = oldProject.copyWith(specifications: updatedSpecs);
      _projectsById[projectId] = updatedProject;
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
      final oldProject = _projectsById[projectId];
      if (oldProject == null) return;
      final updatedSpecs = oldProject.specifications?.map((spec) {
        if (spec.id == resourceSpecificationId) {
          final updatedReservations =
              spec.reservations
                  ?.where((r) => r.id != resourceReservationId)
                  .toList() ??
              [];
          return spec.copyWith(reservations: updatedReservations);
        }
        return spec;
      }).toList();
      final updatedProject = oldProject.copyWith(specifications: updatedSpecs);
      _projectsById[projectId] = updatedProject;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> startProject(int id) async {
    _isLoading = true;
    notifyListeners();

    try {
      final newProject = await _projectService.startProject(id);
      _projectsById[id] = newProject;
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
      final newProject = await _projectService.finishProject(id);
      final oldProject = _projectsById[id];
      if (oldProject == null) return;
      _projectsById[id] = oldProject.copyWith(
        state: newProject.state,
        updatedAt: newProject.updatedAt,
        endDate: newProject.endDate,
        actualRevenue: newProject.actualRevenue,
      );
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
      final newProject = await _projectService.cancelProject(id);
      final oldProject = _projectsById[id];
      if (oldProject == null) return;
      _projectsById[id] = oldProject.copyWith(
        state: newProject.state,
        updatedAt: newProject.updatedAt,
        endDate: newProject.endDate,
        actualRevenue: newProject.actualRevenue,
      );
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateResourceReservation(
    int projectId,
    int specificationId,
    int reservationId,
    double reservedQuantity,
    double usedQuantity,
  ) async {
    _isLoading = true;
    notifyListeners();

    try {
      final request = ProjectUpdateResourceReservation(
        reservedQuantity: reservedQuantity,
        usedQuantity: usedQuantity,
      );
      final newReservation = await _projectService.updateResourceReservation(
        projectId,
        specificationId,
        reservationId,
        request,
      );
      final oldProject = _projectsById[projectId];
      if (oldProject == null) return;
      final updatedSpecs = oldProject.specifications?.map((spec) {
        if (spec.id == specificationId) {
          final updatedReservations = spec.reservations?.map((res) {
            if (res.id == reservationId) {
              return newReservation;
            }
            return res;
          }).toList();
          return spec.copyWith(reservations: updatedReservations);
        }
        return spec;
      }).toList();
      final updatedProject = oldProject.copyWith(specifications: updatedSpecs);
      _projectsById[projectId] = updatedProject;
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
