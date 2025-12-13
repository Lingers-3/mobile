import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:pocketeer_mobile/core/constants/app_constants.dart';
import 'package:pocketeer_mobile/data/models/picture.dart';
import 'package:pocketeer_mobile/data/services/auth_service.dart';

class PictureService {
  final AuthService _authService;

  PictureService({AuthService? authService})
    : _authService = authService ?? AuthService();

  Future<Picture> createPicture(File file) async {
    final token = _authService.ensureToken();

    final uri = Uri.parse("${AppConstants.apiBaseUrl}/pictures");

    final request = http.MultipartRequest("POST", uri)
      ..headers['Authorization'] = "Bearer $token"
      ..files.add(await http.MultipartFile.fromPath("image", file.path));

    final response = await request.send();
    final body = await response.stream.bytesToString();

    if (response.statusCode != 201 && response.statusCode != 200) {
      throw Exception("Upload failed: ${response.statusCode} | $body");
    }

    return Picture.fromJson(jsonDecode(body));
  }

  Future<Picture> getPicture(int id) async {
    final token = _authService.ensureToken();

    final uri = Uri.parse("${AppConstants.apiBaseUrl}/pictures/$id");

    final response = await http.get(
      uri,
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to load picture');
    }

    return Picture.fromJson(jsonDecode(response.body));
  }
}
