import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:pocketeer_mobile/data/models/picture.dart';
import 'package:pocketeer_mobile/data/services/picture_service.dart';

class PictureProvider extends ChangeNotifier {
  final PictureService _pictureService = PictureService();
  PictureService get pictureService => _pictureService;

  bool _isLoading = false;
  String? _error;

  bool get loading => _isLoading;
  String? get errorMessage => _error;

  Future<Picture> getPicture(int id) async {
    _isLoading = true;
    notifyListeners();
    try {
      final picture = await _pictureService.getPicture(id);
      return picture;
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Picture> uploadPicture(File file) async {
    _isLoading = true;
    notifyListeners();
    try {
      final picture = await _pictureService.createPicture(file);
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
