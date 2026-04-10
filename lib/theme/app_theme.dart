import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_radius.dart';
import 'app_spacing.dart';
import 'app_text_styles.dart';

class AppTheme {

  // =========================
  // LIGHT THEME (🔵 Blau)
  // =========================

  static ThemeData lightTheme = ThemeData(

    useMaterial3: true,

    brightness: Brightness.light,

    scaffoldBackgroundColor:
        AppColors.backgroundLight,

    primaryColor:
        AppColors.primaryLight,

    colorScheme: ColorScheme.light(

      primary:
          AppColors.primaryLight,

      secondary:
          AppColors.primaryLight,

      surface:
          AppColors.surfaceLight,

      error:
          AppColors.critical,

    ),

    appBarTheme: const AppBarTheme(

  backgroundColor: Colors.white,

  elevation: 0,

  centerTitle: false,

  titleTextStyle: TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w700,
    color: Color(0xFF111827),
    letterSpacing: 0.2,
  ),

  iconTheme: IconThemeData(
    color: Color(0xFF111827),
  ),

),

    cardTheme: CardThemeData(

      elevation: 0,

      color:
          AppColors.cardLight,

      shape: RoundedRectangleBorder(

        borderRadius:
            AppRadius.radiusMD,

      ),

      margin: EdgeInsets.zero,

    ),

    floatingActionButtonTheme:
        const FloatingActionButtonThemeData(

      backgroundColor:
          AppColors.primaryLight,

      foregroundColor:
          Colors.white,

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

      focusedBorder:
          const OutlineInputBorder(

        borderRadius:
            AppRadius.radiusSM,

        borderSide: BorderSide(

          color:
              AppColors.primaryLight,

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
            AppColors.primaryLight,

        foregroundColor:
            Colors.white,

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
  // DARK THEME (🟣 Lila)
  // =========================

  static ThemeData darkTheme = ThemeData(

    useMaterial3: true,

    brightness: Brightness.dark,

    scaffoldBackgroundColor:
        AppColors.backgroundDark,

    primaryColor:
        AppColors.primaryDark,

    colorScheme: ColorScheme.dark(

      primary:
          AppColors.primaryDark,

      secondary:
          AppColors.primaryDark,

      surface:
          AppColors.surfaceDark,

      error:
          AppColors.critical,

    ),

    appBarTheme: const AppBarTheme(

  backgroundColor: Color(0xFF0F0F14),

  elevation: 0,

  centerTitle: false,

  titleTextStyle: TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w700,
    color: Colors.white,
    letterSpacing: 0.2,
  ),

  iconTheme: IconThemeData(
    color: Colors.white,
  ),

),

    cardTheme: CardThemeData(

      elevation: 0,

      color:
          AppColors.cardDark,

      shape: RoundedRectangleBorder(

        borderRadius:
            AppRadius.radiusMD,

      ),

      margin: EdgeInsets.zero,

    ),

    floatingActionButtonTheme:
        const FloatingActionButtonThemeData(

      backgroundColor:
          AppColors.primaryDark,

      foregroundColor:
          Colors.white,

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

      focusedBorder:
          const OutlineInputBorder(

        borderRadius:
            AppRadius.radiusSM,

        borderSide: BorderSide(

          color:
              AppColors.primaryDark,

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
            AppColors.primaryDark,

        foregroundColor:
            Colors.white,

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