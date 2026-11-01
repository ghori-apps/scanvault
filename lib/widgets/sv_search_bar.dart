import 'package:flutter/material.dart';
import '../config/theme/app_colors.dart';
import '../config/theme/app_typography.dart';

class SVSearchBar extends StatelessWidget {
  final String hintText;
  final ValueChanged<String> onChanged;
  final VoidCallback? onClear;
  final TextEditingController? controller;

  const SVSearchBar({
    super.key,
    this.hintText = 'Search history or content...',
    required this.onChanged,
    this.onClear,
    this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.warmWhite,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark ? const Color(0xFF38322E) : AppColors.borderGray,
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Row(
        children: [
          Icon(
            Icons.search_rounded,
            color: isDark ? AppColors.mediumGray : AppColors.mediumGray,
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: controller,
              onChanged: onChanged,
              style: AppTypography.bodyMedium(isDark: isDark),
              decoration: InputDecoration(
                hintText: hintText,
                hintStyle: AppTypography.bodyMedium(isDark: isDark).copyWith(
                  color: AppColors.mediumGray,
                ),
                border: InputBorder.none,
                isDense: true,
              ),
            ),
          ),
          if (controller != null && controller!.text.isNotEmpty)
            GestureDetector(
              onTap: () {
                controller!.clear();
                onChanged('');
                if (onClear != null) onClear!();
              },
              child: const Icon(
                Icons.close_rounded,
                color: AppColors.mediumGray,
                size: 18,
              ),
            ),
        ],
      ),
    );
  }
}
