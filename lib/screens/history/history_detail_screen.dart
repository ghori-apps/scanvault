import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';
import '../../config/theme/app_colors.dart';
import '../../config/theme/app_typography.dart';
import '../../models/scanned_code.dart';
import '../../providers/history_provider.dart';
import '../../widgets/sv_button.dart';
import '../../widgets/sv_card.dart';

class HistoryDetailScreen extends StatefulWidget {
  final ScannedCode code;

  const HistoryDetailScreen({super.key, required this.code});

  @override
  State<HistoryDetailScreen> createState() => _HistoryDetailScreenState();
}

class _HistoryDetailScreenState extends State<HistoryDetailScreen> {
  late TextEditingController _noteController;

  @override
  void initState() {
    super.initState();
    _noteController = TextEditingController(text: widget.code.note ?? '');
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final history = Provider.of<HistoryProvider>(context);
    final dateStr = DateFormat('MMMM d, yyyy • h:mm a').format(widget.code.scannedAt);
    final parsed = widget.code.parsedContent;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Vault Item Detail'),
        actions: [
          IconButton(
            icon: Icon(
              widget.code.isFavorite ? Icons.star_rounded : Icons.star_outline_rounded,
              color: widget.code.isFavorite ? AppColors.restrainedAmber : null,
            ),
            onPressed: () => history.toggleFavorite(widget.code),
          ),
          IconButton(
            icon: const Icon(Icons.share_rounded),
            onPressed: () => SharePlus.instance.share(ShareParams(text: widget.code.rawValue)),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline_rounded, color: AppColors.dangerRed),
            onPressed: () async {
              await history.deleteScan(widget.code);
              if (context.mounted) Navigator.of(context).pop();
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // QR Code Re-rendering Card
            Center(
              child: SVCard(
                padding: const EdgeInsets.all(20),
                child: QrImageView(
                  data: widget.code.rawValue,
                  version: QrVersions.auto,
                  size: 200.0,
                  eyeStyle: QrEyeStyle(
                    eyeShape: QrEyeShape.square,
                    color: isDark ? AppColors.warmIvory : AppColors.graphite,
                  ),
                  dataModuleStyle: QrDataModuleStyle(
                    dataModuleShape: QrDataModuleShape.square,
                    color: isDark ? AppColors.warmIvory : AppColors.graphite,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Main Parsed Content Box
            SVCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    parsed.title,
                    style: AppTypography.headlineMedium(isDark: isDark),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    dateStr,
                    style: AppTypography.bodySmall(isDark: isDark),
                  ),
                  const Divider(height: 24),
                  Text(
                    'RAW CONTENT',
                    style: AppTypography.labelSmall(isDark: isDark).copyWith(
                      color: AppColors.mediumGray,
                    ),
                  ),
                  const SizedBox(height: 6),
                  SelectableText(
                    widget.code.rawValue,
                    style: AppTypography.bodyMedium(isDark: isDark).copyWith(
                      fontFamily: 'Monospace',
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Metadata Card
            SVCard(
              child: Column(
                children: [
                  _buildMetaRow('Format', widget.code.format, isDark),
                  const Divider(),
                  _buildMetaRow('Content Type', widget.code.contentType.label, isDark),
                  const Divider(),
                  _buildMetaRow('Scan Source', widget.code.source.name.toUpperCase(), isDark),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Copy & Action Buttons
            Row(
              children: [
                Expanded(
                  child: SVButton(
                    label: 'Copy Value',
                    icon: Icons.copy_rounded,
                    variant: SVButtonVariant.secondary,
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: widget.code.rawValue));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Copied to clipboard')),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: SVButton(
                    label: 'Share',
                    icon: Icons.share_rounded,
                    variant: SVButtonVariant.primary,
                    onPressed: () => SharePlus.instance.share(ShareParams(text: widget.code.rawValue)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetaRow(String label, String value, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTypography.labelLarge(isDark: isDark)),
          Text(
            value,
            style: AppTypography.bodyMedium(isDark: isDark).copyWith(
              color: AppColors.electricCoral,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
