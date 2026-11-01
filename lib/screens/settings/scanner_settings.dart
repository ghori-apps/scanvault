import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/settings_provider.dart';
import '../../widgets/sv_card.dart';
import '../../widgets/sv_toggle.dart';

class ScannerSettingsScreen extends StatelessWidget {
  const ScannerSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingsProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Scanner Preferences'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          SVCard(
            child: Column(
              children: [
                SVToggleTile(
                  title: 'Haptic Feedback',
                  subtitle: 'Vibrate on successful code detection',
                  icon: Icons.vibration_rounded,
                  value: settings.vibrationEnabled,
                  onChanged: (v) => settings.toggleVibration(v),
                ),
                const Divider(),
                SVToggleTile(
                  title: 'Sound Feedback',
                  subtitle: 'Play subtle confirmation sound on scan',
                  icon: Icons.volume_up_rounded,
                  value: settings.soundEnabled,
                  onChanged: (v) => settings.toggleSound(v),
                ),
                const Divider(),
                SVToggleTile(
                  title: 'Auto Flashlight',
                  subtitle: 'Automatically turn on torch in low light',
                  icon: Icons.flash_auto_rounded,
                  value: settings.autoTorchEnabled,
                  onChanged: (v) => settings.toggleAutoTorch(v),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
