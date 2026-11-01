class AppConstants {
  AppConstants._();

  static const String appName = 'ScanVault';
  static const String appTagline = 'Premium Privacy-First QR & Barcode Utility';
  static const String appVersion = '1.0.0';

  // Storage Keys
  static const String prefKeyThemeMode = 'theme_mode';
  static const String prefKeyScanSound = 'scan_sound';
  static const String prefKeyScanVibration = 'scan_vibration';
  static const String prefKeyAutoTorch = 'auto_torch';
  static const String prefKeyNeverAutoOpen = 'never_auto_open';
  static const String prefKeyUrlSafetyCheck = 'url_safety_check';
  static const String prefKeyIncognitoMode = 'incognito_mode';
  static const String prefKeyHasSeenOnboarding = 'has_seen_onboarding';
  static const String prefKeyAccentColor = 'accent_color';
  static const String prefKeyContinuousScan = 'continuous_scan';

  // History limits
  static const int maxFreeHistoryItems = 500;
  static const int maxBatchSessionItems = 100;
}
