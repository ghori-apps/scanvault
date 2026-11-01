import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../models/scanned_code.dart';
import '../models/generated_code.dart';

/// Local JSON file storage service with monthly partitioning for history and vault data.
class StorageService {
  late Directory _appDocDir;
  late Directory _historyDir;
  late Directory _generatorDir;

  Future<void> init() async {
    _appDocDir = await getApplicationDocumentsDirectory();
    _historyDir = Directory('${_appDocDir.path}/history');
    _generatorDir = Directory('${_appDocDir.path}/generator');

    if (!await _historyDir.exists()) {
      await _historyDir.create(recursive: true);
    }
    if (!await _generatorDir.exists()) {
      await _generatorDir.create(recursive: true);
    }
  }

  String _getHistoryFileName(DateTime date) {
    final year = date.year;
    final month = date.month.toString().padLeft(2, '0');
    return '${_historyDir.path}/history_${year}_$month.json';
  }

  /// Load all history items across partitioned files, sorted by newest first.
  Future<List<ScannedCode>> loadAllHistory() async {
    final List<ScannedCode> all = [];
    final List<FileSystemEntity> files = _historyDir.listSync();

    for (var file in files) {
      if (file is File && file.path.endsWith('.json')) {
        try {
          final content = await file.readAsString();
          if (content.isNotEmpty) {
            final List<dynamic> list = jsonDecode(content);
            all.addAll(list.map((item) => ScannedCode.fromJson(item)));
          }
        } catch (_) {
          // Gracefully skip corrupted file chunk
        }
      }
    }

    all.sort((a, b) => b.scannedAt.compareTo(a.scannedAt));
    return all;
  }

  /// Save a scanned code to the appropriate monthly JSON file.
  Future<void> saveScannedCode(ScannedCode code) async {
    final filePath = _getHistoryFileName(code.scannedAt);
    final file = File(filePath);
    List<ScannedCode> monthList = [];

    if (await file.exists()) {
      final content = await file.readAsString();
      if (content.isNotEmpty) {
        final List<dynamic> list = jsonDecode(content);
        monthList = list.map((item) => ScannedCode.fromJson(item)).toList();
      }
    }

    // Insert at beginning
    monthList.insert(0, code);

    // Save back to JSON file
    await file.writeAsString(jsonEncode(monthList.map((e) => e.toJson()).toList()));
  }

  /// Update an existing item (e.g. toggle favorite or edit note).
  Future<void> updateScannedCode(ScannedCode code) async {
    final filePath = _getHistoryFileName(code.scannedAt);
    final file = File(filePath);

    if (await file.exists()) {
      final content = await file.readAsString();
      if (content.isNotEmpty) {
        final List<dynamic> list = jsonDecode(content);
        final monthList = list.map((item) => ScannedCode.fromJson(item)).toList();
        final index = monthList.indexWhere((e) => e.id == code.id);
        if (index != -1) {
          monthList[index] = code;
          await file.writeAsString(jsonEncode(monthList.map((e) => e.toJson()).toList()));
        }
      }
    }
  }

  /// Delete a single scan item.
  Future<void> deleteScannedCode(ScannedCode code) async {
    final filePath = _getHistoryFileName(code.scannedAt);
    final file = File(filePath);

    if (await file.exists()) {
      final content = await file.readAsString();
      if (content.isNotEmpty) {
        final List<dynamic> list = jsonDecode(content);
        final monthList = list.map((item) => ScannedCode.fromJson(item)).toList();
        monthList.removeWhere((e) => e.id == code.id);
        await file.writeAsString(jsonEncode(monthList.map((e) => e.toJson()).toList()));
      }
    }
  }

  /// Clear all history.
  Future<void> clearAllHistory() async {
    final List<FileSystemEntity> files = _historyDir.listSync();
    for (var file in files) {
      if (file is File) {
        await file.delete();
      }
    }
  }

  // === GENERATOR STORAGE ===

  Future<List<GeneratedCode>> loadGeneratedCodes() async {
    final file = File('${_generatorDir.path}/my_codes.json');
    if (!await file.exists()) return [];

    try {
      final content = await file.readAsString();
      if (content.isEmpty) return [];
      final List<dynamic> list = jsonDecode(content);
      final codes = list.map((e) => GeneratedCode.fromJson(e)).toList();
      codes.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return codes;
    } catch (_) {
      return [];
    }
  }

  Future<void> saveGeneratedCode(GeneratedCode code) async {
    final current = await loadGeneratedCodes();
    current.insert(0, code);
    final file = File('${_generatorDir.path}/my_codes.json');
    await file.writeAsString(jsonEncode(current.map((e) => e.toJson()).toList()));
  }

  Future<void> deleteGeneratedCode(String id) async {
    final current = await loadGeneratedCodes();
    current.removeWhere((e) => e.id == id);
    final file = File('${_generatorDir.path}/my_codes.json');
    await file.writeAsString(jsonEncode(current.map((e) => e.toJson()).toList()));
  }

  Future<void> clearAllGeneratedCodes() async {
    final file = File('${_generatorDir.path}/my_codes.json');
    if (await file.exists()) {
      await file.delete();
    }
  }
}
