import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:pocketeer_mobile/data/models/picture.dart';
import 'package:pocketeer_mobile/data/services/picture_service.dart';

class PictureProvider extends ChangeNotifier {
  final PictureService _pictureService = PictureService();
  PictureService get pictureService => _pictureService;

  final List<Picture> _pictures = [];
  final Map<int, Uint8List> _pictureBytesCache = <int, Uint8List>{};
  bool _isLoading = false;
  String? _error;

  List<Picture> get pictures => List.unmodifiable(_pictures);
  bool get loading => _isLoading;
  String? get errorMessage => _error;

  Uint8List? getCachedPictureBytes(int id) => _pictureBytesCache[id];

  void _upsertPicture(Picture picture) {
    final idx = _pictures.indexWhere((p) => p.id == picture.id);
    if (idx == -1) {
      _pictures.add(picture);
    } else {
      _pictures[idx] = picture;
    }
  }

  Future<Picture?> getPicture(int id) async {
    final existing = _pictures.where((p) => p.id == id).toList();
    if (existing.isNotEmpty) {
      return existing.first;
    }

    try {
      _error = null;
      final picture = await _pictureService.getPicture(id);
      _upsertPicture(picture);
      return picture;
    } catch (e) {
      _error = e.toString();
      rethrow;
    }
  }

  Future<Picture> uploadPicture(File file) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final picture = await _pictureService.createPicture(file);
      _upsertPicture(picture);
      return picture;
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Uint8List> getPictureBytes(int id) async {
    final cached = _pictureBytesCache[id];
    if (cached != null) return cached;

    final bytes = await _pictureService.getPictureBytes(id);
    _pictureBytesCache[id] = bytes;
    return bytes;
  }
}
