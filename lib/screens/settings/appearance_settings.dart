import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme/app_colors.dart';
import '../../config/theme/app_typography.dart';
import '../../providers/settings_provider.dart';
import '../../widgets/sv_card.dart';

class AppearanceSettingsScreen extends StatelessWidget {
  const AppearanceSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final settings = Provider.of<SettingsProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Appearance'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text('Theme Mode', style: AppTypography.titleMedium(isDark: isDark)),
          const SizedBox(height: 12),
          SVCard(
            child: RadioGroup<ThemeMode>(
              groupValue: settings.themeMode,
              onChanged: (mode) {
                if (mode != null) settings.setThemeMode(mode);
              },
              child: Column(
                children: [
                  RadioListTile<ThemeMode>(
                    title: const Text('System Default'),
                    subtitle: const Text('Match device light/dark appearance'),
                    value: ThemeMode.system,
                    fillColor: WidgetStateProperty.all(AppColors.electricCoral),
                  ),
                  const Divider(),
                  RadioListTile<ThemeMode>(
                    title: const Text('Warm Ivory (Light)'),
                    subtitle: const Text('Light warm ivory background'),
                    value: ThemeMode.light,
                    fillColor: WidgetStateProperty.all(AppColors.electricCoral),
                  ),
                  const Divider(),
                  RadioListTile<ThemeMode>(
                    title: const Text('Deep Graphite (Dark)'),
                    subtitle: const Text('True dark OLED friendly mode'),
                    value: ThemeMode.dark,
                    fillColor: WidgetStateProperty.all(AppColors.electricCoral),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
