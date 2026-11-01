import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/content_type.dart';
import '../models/generated_code.dart';
import '../services/storage_service.dart';

class GeneratorProvider extends ChangeNotifier {
  final StorageService _storageService;
  final _uuid = const Uuid();

  List<GeneratedCode> _myCodes = [];
  bool _isLoading = true;

  GeneratorProvider(this._storageService) {
    loadCodes();
  }

  List<GeneratedCode> get myCodes => _myCodes;
  bool get isLoading => _isLoading;

  Future<void> loadCodes() async {
    _isLoading = true;
    notifyListeners();
    _myCodes = await _storageService.loadGeneratedCodes();
    _isLoading = false;
    notifyListeners();
  }

  Future<GeneratedCode> createCode({
    required String title,
    required String rawValue,
    required CodeContentType contentType,
    QRStyle style = const QRStyle(),
  }) async {
    final code = GeneratedCode(
      id: _uuid.v4(),
      title: title,
      rawValue: rawValue,
      contentType: contentType,
      style: style,
      createdAt: DateTime.now(),
    );

    _myCodes.insert(0, code);
    await _storageService.saveGeneratedCode(code);
    notifyListeners();
    return code;
  }

  Future<void> deleteCode(String id) async {
    _myCodes.removeWhere((e) => e.id == id);
    await _storageService.deleteGeneratedCode(id);
    notifyListeners();
  }

  Future<void> clearAll() async {
    _myCodes.clear();
    await _storageService.clearAllGeneratedCodes();
    notifyListeners();
  }
}
