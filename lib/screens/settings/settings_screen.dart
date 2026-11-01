import 'package:flutter/material.dart';
import '../../config/theme/app_colors.dart';
import '../../config/theme/app_typography.dart';
import '../../widgets/sv_card.dart';
import 'about_screen.dart';
import 'appearance_settings.dart';
import 'data_management.dart';
import 'privacy_settings.dart';
import 'scanner_settings.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          SVCard(
            child: Column(
              children: [
                _buildSettingTile(
                  context,
                  icon: Icons.palette_outlined,
                  title: 'Appearance',
                  subtitle: 'Theme mode, warm ivory / dark mode',
                  destination: const AppearanceSettingsScreen(),
                  isDark: isDark,
                ),
                const Divider(),
                _buildSettingTile(
                  context,
                  icon: Icons.tune_rounded,
                  title: 'Scanner Preferences',
                  subtitle: 'Haptic feedback, sound, flashlight',
                  destination: const ScannerSettingsScreen(),
                  isDark: isDark,
                ),
                const Divider(),
                _buildSettingTile(
                  context,
                  icon: Icons.security_rounded,
                  title: 'Privacy & Security',
                  subtitle: 'Local safety guard, link warning, incognito',
                  destination: const PrivacySettingsScreen(),
                  isDark: isDark,
                ),
                const Divider(),
                _buildSettingTile(
                  context,
                  icon: Icons.folder_zip_outlined,
                  title: 'Data Management',
                  subtitle: 'Export CSV / JSON backup, clear storage',
                  destination: const DataManagementScreen(),
                  isDark: isDark,
                ),
                const Divider(),
                _buildSettingTile(
                  context,
                  icon: Icons.info_outline_rounded,
                  title: 'About ScanVault',
                  subtitle: 'App version, licenses, credits',
                  destination: const AboutScreen(),
                  isDark: isDark,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Widget destination,
    required bool isDark,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.electricCoral.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: AppColors.electricCoral, size: 22),
      ),
      title: Text(title, style: AppTypography.titleMedium(isDark: isDark)),
      subtitle: Text(subtitle, style: AppTypography.bodySmall(isDark: isDark)),
      trailing: const Icon(Icons.chevron_right_rounded, size: 20),
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => destination),
        );
      },
    );
  }
}
