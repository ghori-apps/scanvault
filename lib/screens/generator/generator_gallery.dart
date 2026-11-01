import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../config/theme/app_colors.dart';
import '../../config/theme/app_typography.dart';
import '../../providers/generator_provider.dart';
import '../../widgets/sv_card.dart';
import '../../widgets/sv_empty_state.dart';
import 'generator_preview.dart';

class GeneratorGalleryScreen extends StatelessWidget {
  const GeneratorGalleryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final genProvider = Provider.of<GeneratorProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Created Codes'),
      ),
      body: genProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : (genProvider.myCodes.isEmpty
              ? SVEmptyState(
                  icon: Icons.qr_code_2_rounded,
                  title: 'No Created QR Codes',
                  subtitle: 'Custom QR codes you create will be stored here.',
                )
              : GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 0.82,
                  ),
                  itemCount: genProvider.myCodes.length,
                  itemBuilder: (context, index) {
                    final code = genProvider.myCodes[index];
                    return SVCard(
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => GeneratorPreviewScreen(
                              title: code.title,
                              rawValue: code.rawValue,
                              contentType: code.contentType,
                            ),
                          ),
                        );
                      },
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          QrImageView(
                            data: code.rawValue,
                            version: QrVersions.auto,
                            size: 110.0,
                            eyeStyle: QrEyeStyle(
                              eyeShape: QrEyeShape.square,
                              color: code.style.foregroundColor,
                            ),
                            dataModuleStyle: QrDataModuleStyle(
                              dataModuleShape: QrDataModuleShape.square,
                              color: code.style.foregroundColor,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            code.title,
                            style: AppTypography.titleMedium(isDark: isDark),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                          ),
                          Text(
                            code.contentType.label,
                            style: AppTypography.labelSmall(isDark: isDark).copyWith(
                              color: AppColors.electricCoral,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                )),
    );
  }
}
