import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/content_type.dart';
import '../models/scanned_code.dart';
import '../services/parser_service.dart';
import '../services/storage_service.dart';

class HistoryProvider extends ChangeNotifier {
  final StorageService _storageService;
  final _uuid = const Uuid();

  List<ScannedCode> _history = [];
  bool _isLoading = true;
  String _searchQuery = '';
  CodeContentType? _selectedTypeFilter;
  bool _showFavoritesOnly = false;

  HistoryProvider(this._storageService) {
    loadHistory();
  }

  List<ScannedCode> get history => _history;
  bool get isLoading => _isLoading;
  String get searchQuery => _searchQuery;
  CodeContentType? get selectedTypeFilter => _selectedTypeFilter;
  bool get showFavoritesOnly => _showFavoritesOnly;

  List<ScannedCode> get filteredHistory {
    return _history.where((code) {
      if (_showFavoritesOnly && !code.isFavorite) {
        return false;
      }
      if (_selectedTypeFilter != null && code.contentType != _selectedTypeFilter) {
        return false;
      }
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        final title = code.parsedContent.title.toLowerCase();
        final raw = code.rawValue.toLowerCase();
        return title.contains(query) || raw.contains(query);
      }
      return true;
    }).toList();
  }

  List<ScannedCode> get favorites => _history.where((e) => e.isFavorite).toList();

  Future<void> loadHistory() async {
    _isLoading = true;
    notifyListeners();
    _history = await _storageService.loadAllHistory();
    _isLoading = false;
    notifyListeners();
  }

  Future<ScannedCode> addScan({
    required String rawValue,
    required String format,
    ScanSource source = ScanSource.camera,
    bool isIncognito = false,
  }) async {
    final parsed = ParserService.parse(rawValue, format);
    final scannedCode = ScannedCode(
      id: _uuid.v4(),
      rawValue: rawValue,
      format: format,
      contentType: parsed.type,
      parsedContent: parsed,
      scannedAt: DateTime.now(),
      source: source,
    );

    if (!isIncognito) {
      _history.insert(0, scannedCode);
      await _storageService.saveScannedCode(scannedCode);
      notifyListeners();
    }

    return scannedCode;
  }

  Future<void> toggleFavorite(ScannedCode code) async {
    final index = _history.indexWhere((e) => e.id == code.id);
    if (index != -1) {
      _history[index].isFavorite = !_history[index].isFavorite;
      await _storageService.updateScannedCode(_history[index]);
      notifyListeners();
    }
  }

  Future<void> deleteScan(ScannedCode code) async {
    _history.removeWhere((e) => e.id == code.id);
    await _storageService.deleteScannedCode(code);
    notifyListeners();
  }

  Future<void> clearAll() async {
    _history.clear();
    await _storageService.clearAllHistory();
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setTypeFilter(CodeContentType? type) {
    _selectedTypeFilter = type;
    notifyListeners();
  }

  void toggleFavoritesOnly(bool value) {
    _showFavoritesOnly = value;
    notifyListeners();
  }
}
