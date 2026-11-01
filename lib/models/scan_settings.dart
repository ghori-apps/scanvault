import 'package:flutter/material.dart';

/// App preferences model.
class ScanSettings {
  final ThemeMode themeMode;
  final bool soundEnabled;
  final bool vibrationEnabled;
  final bool autoTorchEnabled;
  final bool neverAutoOpenUrls;
  final bool urlSafetyCheckEnabled;
  final bool incognitoMode;
  final bool continuousScan;

  const ScanSettings({
    this.themeMode = ThemeMode.system,
    this.soundEnabled = true,
    this.vibrationEnabled = true,
    this.autoTorchEnabled = false,
    this.neverAutoOpenUrls = true,
    this.urlSafetyCheckEnabled = true,
    this.incognitoMode = false,
    this.continuousScan = false,
  });

  ScanSettings copyWith({
    ThemeMode? themeMode,
    bool? soundEnabled,
    bool? vibrationEnabled,
    bool? autoTorchEnabled,
    bool? neverAutoOpenUrls,
    bool? urlSafetyCheckEnabled,
    bool? incognitoMode,
    bool? continuousScan,
  }) {
    return ScanSettings(
      themeMode: themeMode ?? this.themeMode,
      soundEnabled: soundEnabled ?? this.soundEnabled,
      vibrationEnabled: vibrationEnabled ?? this.vibrationEnabled,
      autoTorchEnabled: autoTorchEnabled ?? this.autoTorchEnabled,
      neverAutoOpenUrls: neverAutoOpenUrls ?? this.neverAutoOpenUrls,
      urlSafetyCheckEnabled: urlSafetyCheckEnabled ?? this.urlSafetyCheckEnabled,
      incognitoMode: incognitoMode ?? this.incognitoMode,
      continuousScan: continuousScan ?? this.continuousScan,
    );
  }
}
