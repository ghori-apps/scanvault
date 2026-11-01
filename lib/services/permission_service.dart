import 'package:permission_handler/permission_handler.dart';

/// Camera & media permission service for ScanVault.
class PermissionService {
  static Future<PermissionStatus> checkCameraPermission() async {
    return await Permission.camera.status;
  }

  static Future<PermissionStatus> requestCameraPermission() async {
    return await Permission.camera.request();
  }

  static Future<bool> openAppSettingsPage() async {
    return await openAppSettings();
  }
}
