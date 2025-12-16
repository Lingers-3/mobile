import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:pocketeer_mobile/data/models/picture_meta.dart';
import 'package:pocketeer_mobile/data/services/picture_service.dart';

class PictureProvider extends ChangeNotifier {
  final PictureService _pictureService = PictureService();
  PictureService get pictureService => _pictureService;

  final Map<int, PictureMeta> _picturesMetaById = {};

  bool _isLoading = false;
  String? _error;

  bool get loading => _isLoading;
  String? get errorMessage => _error;
  PictureMeta? getMetaById(int id) => _picturesMetaById[id];

  void _upsertPictureMeta(PictureMeta picture) {
    _picturesMetaById[picture.id] = picture;
  }

  Future<PictureMeta?> fetchPictureMeta(int id) async {
    if (_picturesMetaById.containsKey(id)) {
      return _picturesMetaById[id];
    }

    try {
      final picture = await _pictureService.getPicture(id);

      _upsertPictureMeta(picture);
      notifyListeners();

      return picture;
    } catch (e) {
      if (kDebugMode) {
        print("Error fetching picture $id: $e");
      }
      return null;
    }
  }

  Future<PictureMeta> uploadPicture(File file) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final picture = await _pictureService.createPicture(file);
      _upsertPictureMeta(picture);
      return picture;
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
