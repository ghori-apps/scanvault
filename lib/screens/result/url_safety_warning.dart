import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../config/theme/app_colors.dart';
import '../../config/theme/app_typography.dart';
import '../../services/safety_service.dart';
import '../../widgets/sv_button.dart';

class UrlSafetyWarningDialog extends StatelessWidget {
  final String url;
  final SafetyAnalysisResult result;

  const UrlSafetyWarningDialog({
    super.key,
    required this.url,
    required this.result,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final isDanger = result.status == SafetyStatus.dangerous;
    final headerColor = isDanger ? AppColors.dangerRed : AppColors.warningAmber;
    final headerIcon = isDanger ? Icons.gpp_bad_rounded : Icons.shield_rounded;

    return Dialog(
      backgroundColor: isDark ? AppColors.darkCard : AppColors.warmWhite,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: headerColor.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(headerIcon, color: headerColor, size: 36),
            ),
            const SizedBox(height: 16),
            Text(
              result.title,
              style: AppTypography.headlineMedium(isDark: isDark),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              result.description,
              style: AppTypography.bodyMedium(isDark: isDark).copyWith(
                color: AppColors.mediumGray,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),

            // Target URL Box
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurface : AppColors.lightGray,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: isDark ? Colors.white10 : AppColors.borderGray),
              ),
              child: SelectableText(
                url,
                style: AppTypography.bodySmall(isDark: isDark).copyWith(
                  fontFamily: 'Monospace',
                  color: isDark ? AppColors.warmIvory : AppColors.graphite,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 16),

            // Warning flags
            if (result.warningFlags.isNotEmpty) ...[
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: result.warningFlags.map((flag) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2.0),
                    child: Row(
                      children: [
                        Icon(Icons.warning_amber_rounded, size: 14, color: headerColor),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            flag,
                            style: AppTypography.bodySmall(isDark: isDark).copyWith(
                              color: headerColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),
            ],

            // Actions
            Row(
              children: [
                Expanded(
                  child: SVButton(
                    label: 'Cancel',
                    variant: SVButtonVariant.secondary,
                    onPressed: () => Navigator.of(context).pop(false),
                  ),
                ),
                if (!isDanger) ...[
                  const SizedBox(width: 12),
                  Expanded(
                    child: SVButton(
                      label: 'Proceed',
                      variant: SVButtonVariant.danger,
                      onPressed: () {
                        Navigator.of(context).pop(true);
                        launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
                      },
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
