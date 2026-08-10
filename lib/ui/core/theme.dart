import 'package:flutter/material.dart';
import 'colors.dart';
import 'sizes.dart';

ThemeData buildAppTheme() {
  return ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: AppColors.background,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.headerBg,
      primary: AppColors.headerBg,
      secondary: AppColors.tenant,
      surface: AppColors.background,
    ),
    cardTheme: CardThemeData(
      color: AppColors.cardBg,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
        side: const BorderSide(color: Color(0xFFEEEEEE), width: 1),
      ),
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
    ),
    textTheme: const TextTheme(
      headlineMedium: TextStyle(
        fontFamily: 'Outfit',
        fontWeight: FontWeight.bold,
        color: Colors.white,
        fontSize: 28,
      ),
      titleMedium: TextStyle(
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimary,
        fontSize: 18,
      ),
      bodyLarge: TextStyle(
        color: AppColors.textPrimary,
        fontSize: 16,
      ),
      bodyMedium: TextStyle(
        color: AppColors.textSecondary,
        fontSize: 14,
      ),
    ),
  );
}
