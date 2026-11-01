import 'package:flutter/material.dart';
import '../config/theme/app_colors.dart';
import '../config/theme/app_typography.dart';

class SVChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final IconData? icon;

  const SVChip({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final bg = isSelected
        ? AppColors.electricCoral
        : (isDark ? AppColors.darkCard : AppColors.lightGray);
    final fg = isSelected
        ? Colors.white
        : (isDark ? AppColors.warmIvory : AppColors.graphite);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? AppColors.electricCoral
                : (isDark ? const Color(0xFF38322E) : AppColors.borderGray),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 16, color: fg),
              const SizedBox(width: 6),
            ],
            Text(
              label,
              style: AppTypography.labelLarge(isDark: isDark).copyWith(
                color: fg,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
