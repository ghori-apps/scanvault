import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../config/theme/app_colors.dart';
import '../../config/theme/app_typography.dart';
import '../../services/permission_service.dart';
import '../../widgets/sv_button.dart';

class PermissionScreen extends StatelessWidget {
  final VoidCallback onGranted;

  const PermissionScreen({super.key, required this.onGranted});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: AppColors.electricCoral.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.camera_alt_rounded,
                  size: 52,
                  color: AppColors.electricCoral,
                ),
              ),
              const SizedBox(height: 28),
              Text(
                'Camera Access Required',
                style: AppTypography.headlineLarge(isDark: isDark),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                'ScanVault requires camera access to scan QR codes and barcodes live. Your camera stream is processed entirely on your device and is never recorded or saved.',
                style: AppTypography.bodyMedium(isDark: isDark).copyWith(
                  color: AppColors.mediumGray,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 36),
              SVButton(
                label: 'Grant Camera Permission',
                fullWidth: true,
                onPressed: () async {
                  final status = await PermissionService.requestCameraPermission();
                  if (status.isGranted) {
                    onGranted();
                  } else if (status.isPermanentlyDenied) {
                    await PermissionService.openAppSettingsPage();
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
