import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:pocketeer_mobile/core/constants/app_constants.dart';
import 'package:pocketeer_mobile/data/services/auth_service.dart';

class PictureService {
  final AuthService _authService = AuthService();

  Future<int> uploadPicture(File file) async {
    final token = _authService.ensureToken();

    final uri = Uri.parse("${AppConstants.apiBaseUrl}/api/pictures");

    final request = http.MultipartRequest("POST", uri)
      ..headers['Authorization'] = "Bearer $token"
      ..files.add(await http.MultipartFile.fromPath("image", file.path));

    final response = await request.send();
    final body = await response.stream.bytesToString();

    if (response.statusCode != 201 && response.statusCode != 200) {
      throw Exception("Upload failed: ${response.statusCode} | $body");
    }

    final data = jsonDecode(body);
    return data["id"];
  }
}
