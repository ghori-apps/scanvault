import 'package:flutter/material.dart';
import '../../config/constants/app_constants.dart';
import '../../config/theme/app_colors.dart';
import '../../config/theme/app_typography.dart';
import '../../widgets/sv_card.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('About ScanVault'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          // App Logo & Header
          Center(
            child: Column(
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: AppColors.electricCoral,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: const Icon(
                    Icons.qr_code_scanner_rounded,
                    size: 48,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  AppConstants.appName,
                  style: AppTypography.headlineLarge(isDark: isDark),
                ),
                const SizedBox(height: 4),
                Text(
                  AppConstants.appTagline,
                  style: AppTypography.bodySmall(isDark: isDark),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Version ${AppConstants.appVersion}',
                  style: AppTypography.labelSmall(isDark: isDark).copyWith(
                    color: AppColors.electricCoral,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),

          // Features Summary Card
          SVCard(
            child: Column(
              children: [
                _buildInfoRow('Local-First Architecture', 'Runs 100% on-device', isDark),
                const Divider(),
                _buildInfoRow('Scan Engine', 'Google ML Kit + Platform Native', isDark),
                const Divider(),
                _buildInfoRow('Privacy Model', 'Zero data collection', isDark),
                const Divider(),
                _buildInfoRow('Barcode Support', '1D & 2D (12+ Formats)', isDark),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String title, String subtitle, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: AppTypography.titleMedium(isDark: isDark)),
          Text(subtitle, style: AppTypography.bodySmall(isDark: isDark)),
        ],
      ),
    );
  }
}
