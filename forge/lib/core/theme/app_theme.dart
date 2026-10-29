import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_dimensions.dart';
import 'app_colors_extension.dart';
import 'app_text_extension.dart';
import 'app_typography.dart';

/// ForgeApp theme (dark-only, per ADR-037).
///
/// Both [lightTheme] and [darkTheme] return the same dark design-system theme so the
/// app looks correct regardless of which [ThemeMode] the [ThemeBloc] selects.
class AppTheme {
  static ThemeData get lightTheme => _theme;
  static ThemeData get darkTheme => _theme;

  static final ThemeData _theme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: AppColors.bg,
    colorScheme: const ColorScheme.dark(
      // Surfaces
      surface: AppColors.card, // cards, panels, modals
      surfaceContainerHighest: AppColors.cardAlt, // inputs, nested surfaces
      surfaceContainerLowest: AppColors.bg, // page background
      scrim: AppColors.scrimBarrier, // dialog scrim overlay
      // Primary brand (lime)
      primary: AppColors.lime,
      onPrimary: AppColors.bg, // dark text on lime button
      // On-surface text
      onSurface: AppColors.white,
      onSurfaceVariant: AppColors.textMuted,

      // Error / danger
      error: AppColors.danger,
      errorContainer: AppColors.dangerBg,
      onError: AppColors.white,
      onErrorContainer: AppColors.danger,

      // Borders / outlines
      outline: AppColors.border,
      outlineVariant: AppColors.textDim,
    ),
    textTheme: AppTypography.buildTextTheme(),
    extensions: const [AppColorsExtension.dark, AppTextExtension.dark],

    // ElevatedButton — lime primary, 10 px radius
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.lime,
        foregroundColor: AppColors.bg,
        disabledBackgroundColor: AppColors.cardAlt,
        disabledForegroundColor: AppColors.textDim,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(10)),
        ),
        minimumSize: const Size.fromHeight(kButtonHeight),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        textStyle: const TextStyle(
          fontFamily: 'Helvetica Neue',
          fontSize: 14,
          fontWeight: FontWeight.w700,
          letterSpacing: 0,
        ),
      ),
    ),

    // Input fields — 12 px radius, cardAlt fill, design-system borders
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.cardAlt,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.lime, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.danger),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.danger, width: 1.5),
      ),
      labelStyle: const TextStyle(color: AppColors.textMuted),
      hintStyle: const TextStyle(color: AppColors.textDim),
      errorStyle: const TextStyle(
        color: AppColors.danger,
        fontSize: 11,
        fontWeight: FontWeight.w600,
      ),
      // Yields ~44 dp field height with a single-line label
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    ),
  );
}
