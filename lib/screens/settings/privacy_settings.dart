import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme/app_colors.dart';
import '../../config/theme/app_typography.dart';
import '../../providers/settings_provider.dart';
import '../../widgets/sv_card.dart';
import '../../widgets/sv_toggle.dart';

class PrivacySettingsScreen extends StatelessWidget {
  const PrivacySettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final settings = Provider.of<SettingsProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Privacy & Security'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Privacy Banner
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.safeGreen.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.safeGreen),
            ),
            child: Row(
              children: [
                const Icon(Icons.security_rounded, color: AppColors.safeGreen, size: 28),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Local-First Privacy Guard',
                        style: AppTypography.titleMedium(isDark: isDark).copyWith(
                          color: AppColors.safeGreen,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'ScanVault never collects or transmits your scan data off device.',
                        style: AppTypography.bodySmall(isDark: isDark),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          SVCard(
            child: Column(
              children: [
                SVToggleTile(
                  title: 'Never Auto-Open URLs',
                  subtitle: 'Always require explicit confirmation before opening scanned web links',
                  icon: Icons.link_off_rounded,
                  value: settings.neverAutoOpenUrls,
                  onChanged: (v) => settings.toggleNeverAutoOpen(v),
                ),
                const Divider(),
                SVToggleTile(
                  title: 'Offline URL Safety Analysis',
                  subtitle: 'Inspect domains locally for phishing risk and suspicious patterns',
                  icon: Icons.shield_rounded,
                  value: settings.urlSafetyCheckEnabled,
                  onChanged: (v) => settings.toggleUrlSafetyCheck(v),
                ),
                const Divider(),
                SVToggleTile(
                  title: 'Incognito Scanning Mode',
                  subtitle: 'Do not record scans into history vault while enabled',
                  icon: Icons.visibility_off_rounded,
                  value: settings.incognitoMode,
                  onChanged: (v) => settings.toggleIncognitoMode(v),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
