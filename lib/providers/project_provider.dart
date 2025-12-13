import 'package:flutter/material.dart';
import 'package:pocketeer_mobile/data/models/projects/project.dart';
import 'package:pocketeer_mobile/data/models/projects/project_create_request.dart';
import 'package:pocketeer_mobile/data/models/projects/project_update_request.dart';
import 'package:pocketeer_mobile/data/services/mock/mock_project_service.dart';
import 'package:pocketeer_mobile/data/services/project_service.dart';

class ProjectProvider extends ChangeNotifier {
  // final ProjectService _projectService = ProjectService();
  final MockProjectService _projectService = MockProjectService();

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

  Future<void> updateProject(Project updatedProject) async {
    _isLoading = true;
    notifyListeners();

    try {
      final index = _projects.indexWhere((p) => p.id == updatedProject.id);
      if (index != -1) {
        final request = ProjectUpdateRequest.fromProject(updatedProject);
        final result = await _projectService.updateProject(
          updatedProject.id,
          request,
        );
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

  Future<void> startProject(int id) async {
    try {
      // Отримуємо оновлений проект від сервісу
      final updatedProject = await _projectService.startProject(id);

      // Знаходимо і замінюємо його в локальному списку
      final index = _projects.indexWhere((p) => p.id == id);
      if (index != -1) {
        _projects[index] = updatedProject;
        notifyListeners(); // Тепер UI побачить зміни
      }
    } catch (e) {
      // Обробка помилок
      print(e);
    }
  }

  Future<void> finishProject(int id) async {
    try {
      final updatedProject = await _projectService.finishProject(id);

      final index = _projects.indexWhere((p) => p.id == id);
      if (index != -1) {
        _projects[index] = updatedProject;
        notifyListeners();
      }
    } catch (e) {
      print(e);
    }
  }

  Future<void> cancelProject(int id) async {
    try {
      final updatedProject = await _projectService.cancelProject(id);

      final index = _projects.indexWhere((p) => p.id == id);
      if (index != -1) {
        _projects[index] = updatedProject;
        notifyListeners();
      }
    } catch (e) {
      print(e);
    }
  }
}
