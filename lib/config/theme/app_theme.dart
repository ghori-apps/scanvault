import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app_colors.dart';
import 'app_typography.dart';

/// Full ThemeData setup for Light and Dark modes.
class AppTheme {
  AppTheme._();

  static ThemeData lightTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.warmIvory,
      colorScheme: const ColorScheme.light(
        primary: AppColors.electricCoral,
        secondary: AppColors.restrainedAmber,
        surface: AppColors.warmWhite,
        error: AppColors.dangerRed,
        onPrimary: Colors.white,
        onSecondary: Colors.black,
        onSurface: AppColors.graphite,
        onError: Colors.white,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.warmIvory,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: AppColors.graphite),
        titleTextStyle: AppTypography.titleLarge(isDark: false),
        systemOverlayStyle: SystemUiOverlayStyle.dark,
      ),
      cardTheme: CardThemeData(
        color: AppColors.warmWhite,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.borderGray, width: 1),
        ),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.warmWhite,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.warmWhite,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        elevation: 8,
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.borderGray,
        thickness: 1,
        space: 1,
      ),
    );
  }

  static ThemeData darkTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.deepGraphite,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.electricCoral,
        secondary: AppColors.restrainedAmber,
        surface: AppColors.darkSurface,
        error: AppColors.dangerRed,
        onPrimary: Colors.white,
        onSecondary: Colors.black,
        onSurface: AppColors.warmIvory,
        onError: Colors.white,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.deepGraphite,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: AppColors.warmIvory),
        titleTextStyle: AppTypography.titleLarge(isDark: true),
        systemOverlayStyle: SystemUiOverlayStyle.light,
      ),
      cardTheme: CardThemeData(
        color: AppColors.darkCard,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Color(0xFF3D3732), width: 1),
        ),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.darkSurface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.darkSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        elevation: 8,
      ),
      dividerTheme: const DividerThemeData(
        color: Color(0xFF35302C),
        thickness: 1,
        space: 1,
      ),
    );
  }
}

