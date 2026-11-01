import 'package:flutter/material.dart';
import '../config/theme/app_colors.dart';
import '../config/theme/app_typography.dart';
import 'sv_button.dart';

class SVEmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;

  const SVEmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkCard : AppColors.lightGray,
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 40,
              color: AppColors.electricCoral,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            title,
            style: AppTypography.titleLarge(isDark: isDark),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: AppTypography.bodyMedium(isDark: isDark).copyWith(
              color: AppColors.mediumGray,
            ),
            textAlign: TextAlign.center,
          ),
          if (actionLabel != null && onAction != null) ...[
            const SizedBox(height: 24),
            SVButton(
              label: actionLabel!,
              onPressed: onAction,
              variant: SVButtonVariant.secondary,
            ),
          ],
        ],
      ),
    );
  }
}
