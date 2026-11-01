import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../config/theme/app_colors.dart';
import '../../config/theme/app_typography.dart';
import '../../providers/generator_provider.dart';
import '../../providers/history_provider.dart';
import '../../services/export_service.dart';
import '../../widgets/sv_card.dart';

class DataManagementScreen extends StatelessWidget {
  const DataManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final history = Provider.of<HistoryProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Data Management'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text('Backup & Export', style: AppTypography.titleMedium(isDark: isDark)),
          const SizedBox(height: 12),
          SVCard(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.table_chart_rounded, color: AppColors.electricCoral),
                  title: const Text('Export Vault as CSV'),
                  subtitle: const Text('Compatible with Excel and spreadsheets'),
                  onTap: () {
                    final csv = ExportService.toCsv(history.history);
                    SharePlus.instance.share(ShareParams(text: csv, subject: 'ScanVault History (CSV)'));
                  },
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.code_rounded, color: AppColors.electricCoral),
                  title: const Text('Export Vault as JSON'),
                  subtitle: const Text('Full raw structured backup'),
                  onTap: () {
                    final json = ExportService.toJsonString(history.history);
                    SharePlus.instance.share(ShareParams(text: json, subject: 'ScanVault History (JSON)'));
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          Text('Storage Control', style: AppTypography.titleMedium(isDark: isDark)),
          const SizedBox(height: 12),
          SVCard(
            child: ListTile(
              leading: const Icon(Icons.delete_forever_rounded, color: AppColors.dangerRed),
              title: const Text('Clear All Local Data', style: TextStyle(color: AppColors.dangerRed)),
              subtitle: const Text('Permanently delete all scan records and created QR codes'),
              onTap: () {
                showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('Clear All Local Data?'),
                    content: const Text('This action cannot be undone. All vault history will be deleted.'),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
                      TextButton(
                        onPressed: () async {
                          final generator = Provider.of<GeneratorProvider>(context, listen: false);
                          await history.clearAll();
                          await generator.clearAll();
                          if (ctx.mounted) Navigator.pop(ctx);
                        },
                        child: const Text('Delete Everything', style: TextStyle(color: AppColors.dangerRed)),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
