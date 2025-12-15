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

  Future<Uint8List> getPictureBytes(String hash) async {
    final token = _authService.ensureToken();

    final uri = Uri.parse("${AppConstants.baseUrl}/pictures/$hash");

    final response = await http.get(
      uri,
      headers: {'Authorization': 'Bearer $token', 'Accept': 'image/*'},
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to load picture bytes (${response.statusCode})');
    }

    return response.bodyBytes;
  }
}
