import 'package:flutter/material.dart';
import '../models/scan_settings.dart';
import '../services/preferences_service.dart';

class SettingsProvider extends ChangeNotifier {
  final PreferencesService _prefsService;
  late ScanSettings _settings;

  SettingsProvider(this._prefsService) {
    _settings = _prefsService.loadSettings();
  }

  ScanSettings get settings => _settings;
  ThemeMode get themeMode => _settings.themeMode;
  bool get soundEnabled => _settings.soundEnabled;
  bool get vibrationEnabled => _settings.vibrationEnabled;
  bool get autoTorchEnabled => _settings.autoTorchEnabled;
  bool get neverAutoOpenUrls => _settings.neverAutoOpenUrls;
  bool get urlSafetyCheckEnabled => _settings.urlSafetyCheckEnabled;
  bool get incognitoMode => _settings.incognitoMode;
  bool get continuousScan => _settings.continuousScan;
  bool get hasSeenOnboarding => _prefsService.hasSeenOnboarding;

  void updateSettings(ScanSettings newSettings) {
    _settings = newSettings;
    _prefsService.saveSettings(newSettings);
    notifyListeners();
  }

  void setThemeMode(ThemeMode mode) {
    updateSettings(_settings.copyWith(themeMode: mode));
  }

  void toggleSound(bool value) {
    updateSettings(_settings.copyWith(soundEnabled: value));
  }

  void toggleVibration(bool value) {
    updateSettings(_settings.copyWith(vibrationEnabled: value));
  }

  void toggleAutoTorch(bool value) {
    updateSettings(_settings.copyWith(autoTorchEnabled: value));
  }

  void toggleNeverAutoOpen(bool value) {
    updateSettings(_settings.copyWith(neverAutoOpenUrls: value));
  }

  void toggleUrlSafetyCheck(bool value) {
    updateSettings(_settings.copyWith(urlSafetyCheckEnabled: value));
  }

  void toggleIncognitoMode(bool value) {
    updateSettings(_settings.copyWith(incognitoMode: value));
  }

  void toggleContinuousScan(bool value) {
    updateSettings(_settings.copyWith(continuousScan: value));
  }

  Future<void> completeOnboarding() async {
    await _prefsService.setHasSeenOnboarding(true);
    notifyListeners();
  }
}
