import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:pocketeer_mobile/data/models/picture.dart';
import 'package:pocketeer_mobile/data/services/picture_service.dart';

class PictureProvider extends ChangeNotifier {
  final PictureService _pictureService = PictureService();
  PictureService get pictureService => _pictureService;

  // Кеш для метаданих зображень (Picture objects)
  final List<Picture> _pictures = [];

  // !!! ЗМІНА: Кешування байтів тепер відбувається за Hash (String) !!!
  final Map<String, Uint8List> _pictureBytesCache = <String, Uint8List>{};

  bool _isLoading = false;
  String? _error;

  List<Picture> get pictures => List.unmodifiable(_pictures);
  bool get loading => _isLoading;
  String? get errorMessage => _error;

  // !!! ЗМІНА: Допоміжний метод тепер приймає Hash !!!
  Uint8List? getCachedPictureBytesByHash(String hash) =>
      _pictureBytesCache[hash];

  void _upsertPicture(Picture picture) {
    final idx = _pictures.indexWhere((p) => p.id == picture.id);
    if (idx == -1) {
      _pictures.add(picture);
    } else {
      _pictures[idx] = picture;
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

  // !!! НОВИЙ ОПТИМІЗОВАНИЙ МЕТОД: ЗАВЖДИ ВИКОРИСТОВУЙТЕ ЙОГО !!!
  Future<Uint8List> getPictureBytesByHash(String hash) async {
    final cached = _pictureBytesCache[hash];
    if (cached != null) return cached; // Швидкий доступ до кешу

    // Виклик оптимізованого методу в PictureService (один HTTP-запит)
    final bytes = await _pictureService.getPictureBytes(hash);

    _pictureBytesCache[hash] = bytes; // Кешування за хешем
    return bytes;
  }
}
