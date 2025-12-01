import 'package:flutter/foundation.dart';

import 'package:pocketeer_mobile/data/models/tags/tag_full.dart';

import 'package:pocketeer_mobile/data/models/tags/tag_create_request.dart';

import 'package:pocketeer_mobile/data/models/tags/tag_update_request.dart';

import 'package:pocketeer_mobile/data/services/tag_service.dart';



class TagProvider extends ChangeNotifier {

  final TagService _service = TagService();



  List<TagFull> _tags = [];

  bool _loading = false;

  String? _error;



  List<TagFull> get tags => _tags;

  bool get loading => _loading;

  String? get error => _error;



  TagFull? getById(int id) {

    final index = _tags.indexWhere((t) => t.id == id);

    if (index == -1) return null;

    return _tags[index];

  }



  Future<void> loadTags() async {

    _loading = true;

    _error = null;

    notifyListeners();



    try {

      _tags = await _service.getAllTags();

    } catch (e) {

      _error = "Failed to load tags: $e";
    }



    _loading = false;

    notifyListeners();

  }



  Future<TagFull?> createTag(TagCreateRequest req) async {

    try {

      _error = null;

      final created = await _service.createTag(req);

      _tags.add(created);

      notifyListeners();

      return created;

    } catch (e) {

      _error = "Failed to create tag: $e";
      notifyListeners();

      return null;

    }

  }



  Future<TagFull?> updateTag(int id, TagUpdateRequest req) async {

    try {

      _error = null;

      final updated = await _service.updateTag(id, req);



      final index = _tags.indexWhere((t) => t.id == id);

      if (index != -1) {

        _tags[index] = updated;

        notifyListeners();

      }



      return updated;

    } catch (e) {

      _error = "Failed to update tag: $e";
      notifyListeners();

      return null;

    }

  }



  Future<bool> deleteTag(int id) async {

    try {

      _error = null;

      await _service.deleteTag(id);

      _tags.removeWhere((t) => t.id == id);

      notifyListeners();

      return true;

    } catch (e) {

      _error = "Failed to delete tag: $e";
      notifyListeners();

      return false;

    }

  }





  List<int> updateItemTags({

    required List<int> currentTagIds,

    required List<int> newTagIds,

  }) {

    final updated = [...newTagIds];

    return updated;

  }



  List<int> updateItemTypeTags({

    required List<int> currentTagIds,

    required List<int> newTagIds,

  }) {

    final updated = [...newTagIds];

    return updated;

  }





  List<TagFull> tagsForItem(List<int> tagIds) =>

      _tags.where((t) => tagIds.contains(t.id)).toList();



  List<TagFull> tagsNotInItem(List<int> tagIds) =>

      _tags.where((t) => !tagIds.contains(t.id)).toList();



  List<TagFull> search(String query) {

    final lower = query.toLowerCase();

    return _tags.where((t) => t.name.toLowerCase().contains(lower)).toList();

  }

}



