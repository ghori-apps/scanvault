import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';
import '../../config/theme/app_colors.dart';
import '../../config/theme/app_typography.dart';
import '../../models/content_type.dart';
import '../../models/generated_code.dart';
import '../../providers/generator_provider.dart';
import '../../widgets/sv_button.dart';
import '../../widgets/sv_card.dart';

class GeneratorPreviewScreen extends StatefulWidget {
  final String title;
  final String rawValue;
  final CodeContentType contentType;

  const GeneratorPreviewScreen({
    super.key,
    required this.title,
    required this.rawValue,
    required this.contentType,
  });

  @override
  State<GeneratorPreviewScreen> createState() => _GeneratorPreviewScreenState();
}

class _GeneratorPreviewScreenState extends State<GeneratorPreviewScreen> {
  Color _fgColor = AppColors.graphite;
  final Color _bgColor = AppColors.warmIvory;

  final List<Color> _colorOptions = [
    AppColors.graphite,
    AppColors.electricCoral,
    AppColors.restrainedAmber,
    AppColors.subtleGreen,
    const Color(0xFF1E3A8A), // Deep Indigo
    const Color(0xFF4C1D95), // Deep Purple
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final genProvider = Provider.of<GeneratorProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Generated QR Code'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Live Interactive QR Render Card
            SVCard(
              backgroundColor: _bgColor,
              padding: const EdgeInsets.all(24),
              child: QrImageView(
                data: widget.rawValue,
                version: QrVersions.auto,
                size: 220.0,
                eyeStyle: QrEyeStyle(
                  eyeShape: QrEyeShape.square,
                  color: _fgColor,
                ),
                dataModuleStyle: QrDataModuleStyle(
                  dataModuleShape: QrDataModuleShape.square,
                  color: _fgColor,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              widget.title,
              style: AppTypography.headlineMedium(isDark: isDark),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              widget.contentType.label,
              style: AppTypography.bodySmall(isDark: isDark).copyWith(
                color: AppColors.electricCoral,
              ),
            ),
            const SizedBox(height: 24),

            // Foreground Color Selector
            Align(
              alignment: Alignment.centerLeft,
              child: Text('QR Code Color', style: AppTypography.titleMedium(isDark: isDark)),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: _colorOptions.map((color) {
                final isSelected = _fgColor == color;
                return GestureDetector(
                  onTap: () => setState(() => _fgColor = color),
                  child: Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected ? AppColors.electricCoral : Colors.transparent,
                        width: 3,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 32),

            // Actions
            Row(
              children: [
                Expanded(
                  child: SVButton(
                    label: 'Save to Vault',
                    icon: Icons.save_alt_rounded,
                    variant: SVButtonVariant.secondary,
                    onPressed: () async {
                      await genProvider.createCode(
                        title: widget.title,
                        rawValue: widget.rawValue,
                        contentType: widget.contentType,
                        style: QRStyle(
                          foregroundColorHex: _fgColor.toARGB32(),
                          backgroundColorHex: _bgColor.toARGB32(),
                        ),
                      );
                      if (!context.mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Saved to Created Codes gallery!')),
                        );
                        Navigator.of(context).pop();
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: SVButton(
                    label: 'Share Payload',
                    icon: Icons.share_rounded,
                    variant: SVButtonVariant.primary,
                    onPressed: () {
                      SharePlus.instance.share(ShareParams(text: widget.rawValue, subject: widget.title));
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

