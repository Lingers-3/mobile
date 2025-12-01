import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:pocketeer_mobile/core/constants/app_constants.dart';
import 'package:pocketeer_mobile/data/models/tags/tag_full.dart';
import 'package:pocketeer_mobile/data/models/tags/tag_create_request.dart';
import 'package:pocketeer_mobile/data/models/tags/tag_update_request.dart';
import 'package:pocketeer_mobile/data/services/auth_service.dart';

class TagService {
  final AuthService _auth = AuthService();

  String get _baseUrl => "${AppConstants.apiBaseUrl}/api/tags";

  Map<String, String> _headers(String token) => {
    "Content-Type": "application/json",
    "Authorization": "Bearer $token",
  };

  void _log(String message) {
    print(message);
  }

  Future<List<TagFull>> getAllTags() async {
    final token = _auth.credentials?.accessToken;
    if (token == null) throw Exception("Not authorized");

    _log("GET $_baseUrl");
    final response = await http.get(
      Uri.parse(_baseUrl),
      headers: _headers(token),
    );
    _log("GET $_baseUrl -> ${response.statusCode} ${response.body}");

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception("Failed to load tags: ${response.statusCode}");
    }

    final jsonList = jsonDecode(response.body) as List;
    return jsonList.map((e) => TagFull.fromJson(e)).toList();
  }

  Future<TagFull> getTag(int id) async {
    final token = _auth.credentials?.accessToken;
    if (token == null) throw Exception("Not authorized");

    _log("GET $_baseUrl/$id");
    final response = await http.get(
      Uri.parse("$_baseUrl/$id"),
      headers: _headers(token),
    );
    _log("GET $_baseUrl/$id -> ${response.statusCode} ${response.body}");

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception("Failed to load tag: ${response.statusCode}");
    }

    return TagFull.fromJson(jsonDecode(response.body));
  }

  Future<TagFull> createTag(TagCreateRequest req) async {
    final token = _auth.credentials?.accessToken;
    if (token == null) throw Exception("Not authorized");

    _log("POST $_baseUrl payload=${jsonEncode(req.toJson())}");
    final response = await http.post(
      Uri.parse(_baseUrl),
      headers: _headers(token),
      body: jsonEncode(req.toJson()),
    );
    _log("POST $_baseUrl -> ${response.statusCode} ${response.body}");

    if (response.statusCode != 201) {
      throw Exception(
        "Failed to create tag: ${response.statusCode} → ${response.body}",
      );
    }

    return TagFull.fromJson(jsonDecode(response.body));
  }

  Future<TagFull> updateTag(int id, TagUpdateRequest req) async {
    final token = _auth.credentials?.accessToken;
    if (token == null) throw Exception("Not authorized");

    _log("PATCH $_baseUrl/$id payload=${jsonEncode(req.toJson())}");
    final response = await http.patch(
      Uri.parse("$_baseUrl/$id"),
      headers: _headers(token),
      body: jsonEncode(req.toJson()),
    );
    _log("PATCH $_baseUrl/$id -> ${response.statusCode} ${response.body}");

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception(
        "Failed to update tag: ${response.statusCode} → ${response.body}",
      );
    }

    return TagFull.fromJson(jsonDecode(response.body));
  }

  Future<void> deleteTag(int id) async {
    final token = _auth.credentials?.accessToken;
    if (token == null) throw Exception("Not authorized");

    _log("DELETE $_baseUrl/$id");
    final response = await http.delete(
      Uri.parse("$_baseUrl/$id"),
      headers: _headers(token),
    );
    _log("DELETE $_baseUrl/$id -> ${response.statusCode} ${response.body}");

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception(
        "Failed to delete tag: ${response.statusCode} → ${response.body}",
      );
    }
  }
}
