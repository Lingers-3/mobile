import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:pocketeer_mobile/core/constants/app_constants.dart';
import 'package:pocketeer_mobile/data/models/items/item.dart';
import 'package:pocketeer_mobile/data/models/items/item_create_request.dart';
import 'package:pocketeer_mobile/data/models/items/item_update_request.dart';
import 'package:pocketeer_mobile/data/services/auth_service.dart';

class ItemService {
  static const String itemsUrl = '${AppConstants.apiBaseUrl}/api/items';

  final AuthService _authService = AuthService();

  String _ensureToken() {
    final token = _authService.credentials?.accessToken;
    if (token == null) {
      throw Exception('Not authorized');
    }
    return token;
  }

  Future<List<Item>> getAllItems() async {
    final token = _ensureToken();

    final response = await http.get(
      Uri.parse(itemsUrl),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode != 200) {
      if (kDebugMode) {
        print('❌ Failed to fetch items: ${response.statusCode}');
        print(response.body);
      }
      throw Exception('Failed to fetch items');
    }

    final List<dynamic> data = jsonDecode(response.body);

    if (kDebugMode) {
      final formattedJson = const JsonEncoder.withIndent('  ').convert(data);
      debugPrint('📥 Fetched items:\n$formattedJson');
    }

    // Filter out soft-deleted items
    final filteredData = data.where((e) => e['deleted_at'] == null).toList();

    return filteredData.map((json) => Item.fromJson(json)).toList();
  }

  Future<Item> getItem(int id) async {
    final token = _ensureToken();

    final response = await http.get(
      Uri.parse('$itemsUrl/$id'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to load item');
    }

    return Item.fromJson(jsonDecode(response.body));
  }

  Future<Item> createItem(ItemCreateRequest request) async {
    final token = _ensureToken();

    final requestBody = jsonEncode(request.toJson());

    if (kDebugMode) {
      print(
        '📤 Sending Item Create Request: $requestBody',
      );
    }

    final response = await http.post(
      Uri.parse(itemsUrl),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: requestBody,
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      if (kDebugMode) {
        print('❌ Failed to create item: ${response.statusCode}');
        print(response.body);
      }
      throw Exception('Failed to create item');
    }

    if (kDebugMode) {
      print('✅ Item created');
    }

    return Item.fromJson(jsonDecode(response.body));
  }

  Future<Item> updateItem(int id, ItemUpdateRequest request) async {
    final token = _ensureToken();

    final body = request.toJson();
    if (body.isEmpty) {
      throw Exception('Nothing to update');
    }

    final response = await http.patch(
      Uri.parse('$itemsUrl/$id'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(body),
    );

    if (response.statusCode != 200) {
      if (kDebugMode) {
        print('❌ Failed to update item: ${response.statusCode}');
        print(response.body);
      }
      throw Exception('Failed to update item');
    }

    return Item.fromJson(jsonDecode(response.body));
  }

  Future<void> deleteItem(int id, {bool hard = false}) async {
    final token = _ensureToken();

    final uri = hard
        ? Uri.parse('$itemsUrl/$id?force=true')
        : Uri.parse('$itemsUrl/$id');

    final response = await http.delete(
      uri,
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Failed to delete item');
    }
  }
}
