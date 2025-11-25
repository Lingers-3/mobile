import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:pocketeer_mobile/core/constants/app_constants.dart';
import 'package:pocketeer_mobile/data/models/item_type.dart';
import 'package:pocketeer_mobile/data/models/item_type_create_request.dart';
import 'package:pocketeer_mobile/data/models/item_type_update_request.dart';
import 'package:pocketeer_mobile/data/services/auth_service.dart';

class ItemTypeService {
  static const String itemTypesUrl =
      '${AppConstants.apiBaseUrl}/api/item-types';

  final AuthService _authService = AuthService();

  String _ensureToken() {
    final token = _authService.credentials?.accessToken;
    if (token == null) {
      throw Exception('User not authenticated');
    }
    return token;
  }

  Future<List<ItemType>> getAllItemTypes() async {
    final token = _ensureToken();

    final response = await http.get(
      Uri.parse(itemTypesUrl),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode != 200) {
      if (kDebugMode) {
        print('❌ Failed to fetch item types: ${response.statusCode}');
        print(response.body);
      }
      throw Exception('Failed to fetch item types');
    }

    final List<dynamic> data = jsonDecode(response.body);

    if (kDebugMode) {
      final formattedJson = const JsonEncoder.withIndent('  ').convert(data);
      debugPrint('✅ Fetched item types:\n$formattedJson');
    }

    final filteredData = data.where((e) => e['deleted_at'] == null).toList();

    return filteredData.map((e) => ItemType.fromJson(e)).toList();
  }

  Future<ItemType> getItemType(int id) async {
    final token = _ensureToken();

    final response = await http.get(
      Uri.parse('$itemTypesUrl/$id'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode != 200) {
      if (kDebugMode) {
        print('❌ Failed to load item type: ${response.statusCode}');
        print(response.body);
      }
      throw Exception('Failed to load item type');
    }

    final Map<String, dynamic> json = jsonDecode(response.body);
    return ItemType.fromJson(json);
  }

  Future<ItemType> createItemType(ItemTypeCreateRequest request) async {
    final token = _ensureToken();

    final response = await http.post(
      Uri.parse(itemTypesUrl),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(request.toJson()),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      if (kDebugMode) {
        print('❌ Failed to create item type: ${response.statusCode}');
        print(response.body);
      }
      throw Exception('Failed to create item type');
    }

    if (kDebugMode) {
      print('✅ Item type created successfully!');
      print(response.body);
    }

    final Map<String, dynamic> json = jsonDecode(response.body);
    return ItemType.fromJson(json);
  }

  Future<ItemType> updateItemType(int id, ItemTypeUpdateRequest request) async {
    final token = _ensureToken();

    final body = request.toJson();
    if (body.isEmpty) {
      throw Exception('Nothing to update');
    }

    final response = await http.patch(
      Uri.parse('$itemTypesUrl/$id'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(body),
    );

    if (response.statusCode != 200) {
      if (kDebugMode) {
        print('❌ Failed to update item type: ${response.statusCode}');
        print(response.body);
      }
      throw Exception('Failed to update item type');
    }

    if (kDebugMode) {
      print('✅ Item type updated successfully!');
    }

    final Map<String, dynamic> json = jsonDecode(response.body);
    return ItemType.fromJson(json);
  }

  Future<void> deleteItemType(int id, {bool hard = false}) async {
    final token = _ensureToken();

    final uri = hard
        ? Uri.parse('$itemTypesUrl/$id?force=true')
        : Uri.parse('$itemTypesUrl/$id');

    final response = await http.delete(
      uri,
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode != 200 && response.statusCode != 204) {
      if (kDebugMode) {
        print('❌ Failed to delete item type: ${response.statusCode}');
        print(response.body);
      }
      throw Exception('Failed to delete item type');
    }

    if (kDebugMode) {
      print('✅ Item type deleted successfully! (hard=$hard)');
    }
  }
}
