import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/constants/app_constants.dart';
import '../models/scan_settings.dart';

/// Local SharedPreferences storage wrapper for user settings & state.
class PreferencesService {
  final SharedPreferences _prefs;

  PreferencesService(this._prefs);

  static Future<PreferencesService> init() async {
    final prefs = await SharedPreferences.getInstance();
    return PreferencesService(prefs);
  }

  ScanSettings loadSettings() {
    final themeIndex = _prefs.getInt(AppConstants.prefKeyThemeMode) ?? 0;
    final sound = _prefs.getBool(AppConstants.prefKeyScanSound) ?? true;
    final vibration = _prefs.getBool(AppConstants.prefKeyScanVibration) ?? true;
    final torch = _prefs.getBool(AppConstants.prefKeyAutoTorch) ?? false;
    final neverOpen = _prefs.getBool(AppConstants.prefKeyNeverAutoOpen) ?? true;
    final safetyCheck = _prefs.getBool(AppConstants.prefKeyUrlSafetyCheck) ?? true;
    final incognito = _prefs.getBool(AppConstants.prefKeyIncognitoMode) ?? false;
    final continuous = _prefs.getBool(AppConstants.prefKeyContinuousScan) ?? false;

    return ScanSettings(
      themeMode: ThemeMode.values[themeIndex.clamp(0, ThemeMode.values.length - 1)],
      soundEnabled: sound,
      vibrationEnabled: vibration,
      autoTorchEnabled: torch,
      neverAutoOpenUrls: neverOpen,
      urlSafetyCheckEnabled: safetyCheck,
      incognitoMode: incognito,
      continuousScan: continuous,
    );
  }

  Future<void> saveSettings(ScanSettings settings) async {
    await _prefs.setInt(AppConstants.prefKeyThemeMode, settings.themeMode.index);
    await _prefs.setBool(AppConstants.prefKeyScanSound, settings.soundEnabled);
    await _prefs.setBool(AppConstants.prefKeyScanVibration, settings.vibrationEnabled);
    await _prefs.setBool(AppConstants.prefKeyAutoTorch, settings.autoTorchEnabled);
    await _prefs.setBool(AppConstants.prefKeyNeverAutoOpen, settings.neverAutoOpenUrls);
    await _prefs.setBool(AppConstants.prefKeyUrlSafetyCheck, settings.urlSafetyCheckEnabled);
    await _prefs.setBool(AppConstants.prefKeyIncognitoMode, settings.incognitoMode);
    await _prefs.setBool(AppConstants.prefKeyContinuousScan, settings.continuousScan);
  }

  bool get hasSeenOnboarding => _prefs.getBool(AppConstants.prefKeyHasSeenOnboarding) ?? false;

  Future<void> setHasSeenOnboarding(bool value) async {
    await _prefs.setBool(AppConstants.prefKeyHasSeenOnboarding, value);
  }
}
