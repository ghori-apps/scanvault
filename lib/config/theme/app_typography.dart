import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// Typography tokens for ScanVault using Google Fonts (Inter).
class AppTypography {
  AppTypography._();

  static TextStyle headlineLarge({bool isDark = false}) => GoogleFonts.inter(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.5,
        color: isDark ? AppColors.warmIvory : AppColors.graphite,
      );

  static TextStyle headlineMedium({bool isDark = false}) => GoogleFonts.inter(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.25,
        color: isDark ? AppColors.warmIvory : AppColors.graphite,
      );

  static TextStyle titleLarge({bool isDark = false}) => GoogleFonts.inter(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        letterSpacing: 0,
        color: isDark ? AppColors.warmIvory : AppColors.graphite,
      );

  static TextStyle titleMedium({bool isDark = false}) => GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.15,
        color: isDark ? AppColors.warmIvory : AppColors.graphite,
      );

  static TextStyle bodyLarge({bool isDark = false}) => GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.5,
        color: isDark ? AppColors.warmIvory : AppColors.graphite,
      );

  static TextStyle bodyMedium({bool isDark = false}) => GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.25,
        color: isDark ? AppColors.warmIvory : AppColors.graphite,
      );

  static TextStyle bodySmall({bool isDark = false}) => GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.4,
        color: isDark ? AppColors.mediumGray : AppColors.mediumGray,
      );

  static TextStyle labelLarge({bool isDark = false}) => GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.1,
        color: isDark ? AppColors.warmIvory : AppColors.graphite,
      );

  static TextStyle labelSmall({bool isDark = false}) => GoogleFonts.inter(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.5,
        color: isDark ? AppColors.mediumGray : AppColors.mediumGray,
      );
}
