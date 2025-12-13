import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:pocketeer_mobile/core/constants/app_constants.dart';
import 'package:pocketeer_mobile/data/models/projects/project.dart';
import 'package:pocketeer_mobile/data/models/projects/project_create_request.dart';
import 'package:pocketeer_mobile/data/models/projects/project_update_actual_request.dart';
import 'package:pocketeer_mobile/data/models/projects/project_update_plan_request.dart';
import 'package:pocketeer_mobile/data/models/projects/project_update_request.dart';
import 'package:pocketeer_mobile/data/services/auth_service.dart';

class ProjectService {
  static const String projectsUrl = '${AppConstants.apiBaseUrl}/projects';
  final AuthService _authService;

  ProjectService({AuthService? authService})
    : _authService = authService ?? AuthService();

  Future<List<Project>> getAllProjects() async {
    final token = _authService.ensureToken();

    final uri = Uri.parse(projectsUrl);
    final request = http.get(uri, headers: {'Authorization': 'Bearer $token'});
    final response = await request;

    if (response.statusCode != 200) {
      if (kDebugMode) {
        print('❌ Failed to fetch projects: ${response.statusCode}');
        print(response.body);
      }
      throw Exception('Failed to fetch projects');
    }

    final List<dynamic> data = jsonDecode(response.body);
    final List<Project> projects = data
        .map((json) => Project.fromJson(json))
        .toList();

    return projects;
  }

  Future<Project> getProject(int id) async {
    final token = _authService.ensureToken();

    final uri = Uri.parse('$projectsUrl/$id');
    final request = http.get(uri, headers: {'Authorization': 'Bearer $token'});
    final response = await request;

    if (response.statusCode != 200) {
      if (kDebugMode) {
        print('❌ Failed to load project: ${response.statusCode}');
        print(response.body);
      }
      throw Exception('Failed to load project');
    }

    final data = jsonDecode(response.body);
    final project = Project.fromJson(data);

    return project;
  }

  Future<Project> createProject(ProjectCreateRequest requestBody) async {
    final token = _authService.ensureToken();

    final uri = Uri.parse(projectsUrl);
    final request = http.post(
      uri,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(requestBody.toJson()),
    );
    final response = await request;

    if (response.statusCode != 200 && response.statusCode != 201) {
      if (kDebugMode) {
        print('❌ Failed to create project: ${response.statusCode}');
        print(response.body);
      }
      throw Exception('Failed to create project');
    }

    final project = Project.fromJson(jsonDecode(response.body));

    return project;
  }

  Future<Project> updateProjectPlan(
    int id,
    ProjectUpdatePlanRequest requestBody,
  ) async {
    final token = _authService.ensureToken();

    final uri = Uri.parse('$projectsUrl/$id/plan');
    final request = http.patch(
      uri,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(requestBody.toJson()),
    );
    final response = await request;

    if (response.statusCode != 200) {
      if (kDebugMode) {
        print('❌ Failed to update project plan: ${response.statusCode}');
        print(response.body);
      }
      throw Exception('Failed to update project plan');
    }

    final data = jsonDecode(response.body);
    final project = Project.fromJson(data);

    return project;
  }

  Future<Project> updateProjectActual(
    int id,
    ProjectUpdateActualRequest requestBody,
  ) async {
    final token = _authService.ensureToken();

    final uri = Uri.parse('$projectsUrl/$id/actual');
    final request = http.patch(
      uri,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(requestBody.toJson()),
    );
    final response = await request;

    if (response.statusCode != 200) {
      if (kDebugMode) {
        print('❌ Failed to update project actual: ${response.statusCode}');
        print(response.body);
      }
      throw Exception('Failed to update project actual');
    }

    final data = jsonDecode(response.body);
    final project = Project.fromJson(data);

    return project;
  }

  Future<Project> updateProjectInfo(
    int id,
    ProjectUpdateRequest requestBody,
  ) async {
    final token = _authService.ensureToken();

    final uri = Uri.parse('$projectsUrl/$id');
    final request = http.patch(
      uri,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(requestBody.toJson()),
    );
    final response = await request;

    if (response.statusCode != 200) {
      if (kDebugMode) {
        print('❌ Failed to update project info: ${response.statusCode}');
        print(response.body);
      }
      throw Exception('Failed to update project info');
    }

    final data = jsonDecode(response.body);
    final project = Project.fromJson(data);

    return project;
  }

  Future<void> deleteProject(int id) async {
    final token = _authService.ensureToken();

    final uri = Uri.parse('$projectsUrl/$id');
    final request = http.delete(
      uri,
      headers: {'Authorization': 'Bearer $token'},
    );
    final response = await request;

    if (response.statusCode != 200 || response.statusCode != 204) {
      if (kDebugMode) {
        print('❌ Failed to delete project: ${response.statusCode}');
        print(response.body);
      }
      throw Exception('Failed to delete project');
    }
  }

  // NOTE(saloway): may cause creation of new resource reservations
  Future<Project> startProject(int id) async {
    final token = _authService.ensureToken();

    final uri = Uri.parse('$projectsUrl/$id/start');
    final request = http.post(
      uri,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'id': id}),
    );
    final response = await request;

    if (response.statusCode != 200) {
      if (kDebugMode) {
        print('❌ Failed to start project: ${response.statusCode}');
        print(response.body);
      }
      throw Exception('Failed to start project');
    }

    final data = jsonDecode(response.body);
    final project = Project.fromJson(data);

    return project;
  }

  // NOTE(saloway): may cause change of items
  Future<Project> finishProject(int id) async {
    throw UnimplementedError();
  }

  // NOTE(saloway): may cause change of items
  Future<Project> cancelProject(int id) async {
    final token = _authService.ensureToken();

    final uri = Uri.parse('$projectsUrl/$id/cancel');
    final request = http.post(
      uri,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'id': id}),
    );
    final response = await request;

    if (response.statusCode != 200) {
      if (kDebugMode) {
        print('❌ Failed to start project: ${response.statusCode}');
        print(response.body);
      }
      throw Exception('Failed to start project');
    }

    final data = jsonDecode(response.body);
    final project = Project.fromJson(data);

    return project;
  }
}
