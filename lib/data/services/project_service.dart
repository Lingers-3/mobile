import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:pocketeer_mobile/core/constants/app_constants.dart';
import 'package:pocketeer_mobile/data/models/projects/project.dart';
import 'package:pocketeer_mobile/data/models/projects/project_create_request.dart';
import 'package:pocketeer_mobile/data/models/projects/project_update_request.dart';
import 'package:pocketeer_mobile/data/services/auth_service.dart';

class ProjectService {
  static const String projectsUrl = '${AppConstants.apiBaseUrl}/api/projects';
  final AuthService _authService = AuthService();

  String _ensureToken() {
    final token = _authService.credentials?.accessToken;
    if (token == null) {
      throw Exception('Not authorized');
    }
    return token;
  }

  Future<List<Project>> getAllProjects() async {
    final token = _ensureToken();

    final response = await http.get(
      Uri.parse(projectsUrl),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode != 200) {
      if (kDebugMode) {
        print('❌ Failed to fetch projects: ${response.statusCode}');
        print(response.body);
      }
      throw Exception('Failed to fetch projects');
    }

    final List<dynamic> data = jsonDecode(response.body);

    final filteredData = data.where((e) => e['deleted_at'] == null).toList();

    return filteredData.map((json) => Project.fromJson(json)).toList();
  }

  Future<Project> getProject(int id) async {
    final token = _ensureToken();

    final response = await http.get(
      Uri.parse('$projectsUrl/$id'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to load project');
    }

    return Project.fromJson(jsonDecode(response.body));
  }

  Future<Project> createProject(ProjectCreateRequest request) async {
    final token = _ensureToken();

    final response = await http.post(
      Uri.parse(projectsUrl),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(request.toJson()),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      if (kDebugMode) {
        print('❌ Failed to create project: ${response.statusCode}');
        print(response.body);
      }
      throw Exception('Failed to create project');
    }

    return Project.fromJson(jsonDecode(response.body));
  }

  Future<Project> updateProject(
    int id,
    ProjectUpdateRequest request,
  ) async {
    final token = _ensureToken();

    final response = await http.patch(
      Uri.parse('$projectsUrl/$id'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(request.toJson()),
    );

    if (response.statusCode != 200) {
      if (kDebugMode) {
        print('❌ Failed to update project: ${response.statusCode}');
        print(response.body);
      }
      throw Exception('Failed to update project');
    }

    return Project.fromJson(jsonDecode(response.body));
  }

  Future<void> deleteProject(int id) async {
    final token = _ensureToken();

    final response = await http.delete(
      Uri.parse('$projectsUrl/$id'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Failed to delete project');
    }
  }
}
