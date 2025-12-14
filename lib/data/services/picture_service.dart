import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:pocketeer_mobile/core/constants/app_constants.dart';
import 'package:pocketeer_mobile/data/models/picture.dart';
import 'package:pocketeer_mobile/data/services/auth_service.dart';

class PictureService {
  final AuthService _authService = AuthService();

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
    if (kDebugMode) {
      print(body);
    }
    return Picture.fromJson(jsonDecode(body));
  }

  Future<Uint8List> getPictureBytes(int id) async {
    final token = _authService.ensureToken();

    final uri = Uri.parse("${AppConstants.apiBaseUrl}/pictures/$id");

    final response = await http.get(
      uri,
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'image/*,application/json',
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to load picture bytes (${response.statusCode})');
    }

    final contentType = response.headers['content-type'] ?? '';
    if (contentType.contains('application/json')) {
      // Go `encoding/json` encodes `[]byte` as base64 string.
      final decoded = jsonDecode(response.body);
      if (decoded is Map<String, dynamic>) {
        final content = decoded['content'];
        if (content is String && content.isNotEmpty) {
          return base64Decode(content);
        }
      }

      throw Exception('Picture response JSON has no `content`');
    }

    return response.bodyBytes;
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
