import 'package:flutter/material.dart';
import '../config/theme/app_colors.dart';
import '../config/theme/app_typography.dart';

class SVToggleTile extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData? icon;
  final bool value;
  final ValueChanged<bool> onChanged;

  const SVToggleTile({
    super.key,
    required this.title,
    this.subtitle,
    this.icon,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
      child: Row(
        children: [
          if (icon != null) ...[
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkCard : AppColors.lightGray,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                size: 20,
                color: isDark ? AppColors.warmIvory : AppColors.graphite,
              ),
            ),
            const SizedBox(width: 14),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTypography.titleMedium(isDark: isDark),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle!,
                    style: AppTypography.bodySmall(isDark: isDark),
                  ),
                ],
              ],
            ),
          ),
          Switch.adaptive(
            value: value,
            onChanged: onChanged,
            activeThumbColor: AppColors.electricCoral,
          ),
        ],
      ),
    );
  }
}
