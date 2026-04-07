import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_radius.dart';
import 'app_spacing.dart';
import 'app_text_styles.dart';

class AppTheme {

  // =========================
  // LIGHT THEME
  // =========================

  static ThemeData lightTheme = ThemeData(

    useMaterial3: true,

    brightness: Brightness.light,

    scaffoldBackgroundColor:
        AppColors.backgroundLight,

    primaryColor: AppColors.primary,

    colorScheme: ColorScheme.light(
      primary: AppColors.primary,
      secondary: AppColors.secondary,
      surface: AppColors.surfaceLight,
      error: AppColors.critical,
    ),

    appBarTheme: const AppBarTheme(
      elevation: 0,
      centerTitle: false,
      backgroundColor: AppColors.surfaceLight,
      foregroundColor:
          AppColors.textPrimaryLight,
      titleTextStyle: AppTextStyles.title,
    ),

    // 🔥 FIX: CardThemeData statt CardTheme
    cardTheme: CardThemeData(
      elevation: 0,
      color: AppColors.cardLight,
      shape: RoundedRectangleBorder(
        borderRadius: AppRadius.radiusMD,
      ),
      margin: EdgeInsets.zero,
    ),

    floatingActionButtonTheme:
        const FloatingActionButtonThemeData(
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.white,
    ),

    inputDecorationTheme:
        InputDecorationTheme(

      filled: true,
      fillColor: Colors.white,

      border: OutlineInputBorder(
        borderRadius:
            AppRadius.radiusSM,
      ),

      enabledBorder: OutlineInputBorder(
        borderRadius:
            AppRadius.radiusSM,
        borderSide: BorderSide(
          color: Colors.grey.shade300,
        ),
      ),

      focusedBorder: const OutlineInputBorder(
        borderRadius:
            AppRadius.radiusSM,
        borderSide: BorderSide(
          color: AppColors.primary,
          width: 2,
        ),
      ),

      contentPadding:
          AppSpacing.paddingLG,

    ),

    elevatedButtonTheme:
        ElevatedButtonThemeData(

      style: ElevatedButton.styleFrom(

        backgroundColor:
            AppColors.primary,

        foregroundColor: Colors.white,

        shape: RoundedRectangleBorder(
          borderRadius:
              AppRadius.radiusSM,
        ),

        padding:
            AppSpacing.paddingMD,

      ),
    ),

    textTheme: const TextTheme(

      headlineLarge:
          AppTextStyles.headline,

      titleLarge:
          AppTextStyles.title,

      bodyLarge:
          AppTextStyles.body,

      bodyMedium:
          AppTextStyles.body,

      labelLarge:
          AppTextStyles.bodyBold,

    ),

  );

  // =========================
  // DARK THEME
  // =========================

  static ThemeData darkTheme = ThemeData(

    useMaterial3: true,

    brightness: Brightness.dark,

    scaffoldBackgroundColor:
        AppColors.backgroundDark,

    primaryColor: AppColors.primary,

    colorScheme: ColorScheme.dark(
      primary: AppColors.primary,
      secondary: AppColors.secondary,
      surface: AppColors.surfaceDark,
      error: AppColors.critical,
    ),

    appBarTheme: const AppBarTheme(
      elevation: 0,
      centerTitle: false,
      backgroundColor:
          AppColors.surfaceDark,
      foregroundColor:
          AppColors.textPrimaryDark,
      titleTextStyle:
          AppTextStyles.title,
    ),

    // 🔥 FIX hier auch
    cardTheme: CardThemeData(
      elevation: 0,
      color: AppColors.cardDark,
      shape: RoundedRectangleBorder(
        borderRadius:
            AppRadius.radiusMD,
      ),
      margin: EdgeInsets.zero,
    ),

    floatingActionButtonTheme:
        const FloatingActionButtonThemeData(
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.white,
    ),

    inputDecorationTheme:
        InputDecorationTheme(

      filled: true,
      fillColor:
          AppColors.surfaceDark,

      border: OutlineInputBorder(
        borderRadius:
            AppRadius.radiusSM,
      ),

      enabledBorder: OutlineInputBorder(
        borderRadius:
            AppRadius.radiusSM,
        borderSide: BorderSide(
          color: Colors.grey.shade700,
        ),
      ),

      focusedBorder: const OutlineInputBorder(
        borderRadius:
            AppRadius.radiusSM,
        borderSide: BorderSide(
          color: AppColors.primary,
          width: 2,
        ),
      ),

      contentPadding:
          AppSpacing.paddingLG,

    ),

    elevatedButtonTheme:
        ElevatedButtonThemeData(

      style: ElevatedButton.styleFrom(

        backgroundColor:
            AppColors.primary,

        foregroundColor: Colors.white,

        shape: RoundedRectangleBorder(
          borderRadius:
              AppRadius.radiusSM,
        ),

        padding:
            AppSpacing.paddingMD,

      ),
    ),

    textTheme: const TextTheme(

      headlineLarge:
          AppTextStyles.headline,

      titleLarge:
          AppTextStyles.title,

      bodyLarge:
          AppTextStyles.body,

      bodyMedium:
          AppTextStyles.body,

      labelLarge:
          AppTextStyles.bodyBold,

    ),

  );

}