import 'package:flutter/material.dart';

import 'app_colors.dart';

/// ForgeApp design system type scale.
///
/// Font stack: 'Helvetica Neue', Arial, sans-serif (system fonts — no external loading).
/// On iOS 'Helvetica Neue' is available natively; on Android Flutter falls back to the
/// platform system sans-serif.
class AppTypography {
  static const String _fontFamily = 'Helvetica Neue';

  // Timer readout — 44 / 800
  static const TextStyle _displayLarge = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 44,
    fontWeight: FontWeight.w800,
    color: AppColors.white,
    letterSpacing: 0.88,
  );

  // Large stat value — 19 / 800
  static const TextStyle _displayMedium = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 19,
    fontWeight: FontWeight.w800,
    color: AppColors.white,
    letterSpacing: 0,
  );

  // Compact stat value / small app-bar title — 15 / 800
  static const TextStyle _displaySmall = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 15,
    fontWeight: FontWeight.w800,
    color: AppColors.white,
    letterSpacing: 0,
  );

  // Hero title — 20 / 800
  static const TextStyle _headlineLarge = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 20,
    fontWeight: FontWeight.w800,
    color: AppColors.white,
    letterSpacing: 0,
  );

  // Dialog / empty-state title — 16 / 800
  static const TextStyle _headlineSmall = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w800,
    color: AppColors.white,
    letterSpacing: 0,
  );

  // Item name — 13 / 700
  static const TextStyle _titleSmall = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 13,
    fontWeight: FontWeight.w700,
    color: AppColors.white,
    letterSpacing: 0,
  );

  // Page Title — 22 / 800 (root-tab & app-bar titles)
  static const TextStyle _headlineMedium = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 22,
    fontWeight: FontWeight.w800,
    color: AppColors.white,
    letterSpacing: 0,
  );

  // Screen Title — 18 / 800 (detail-screen app-bar titles)
  static const TextStyle _titleLarge = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 18,
    fontWeight: FontWeight.w800,
    color: AppColors.white,
    letterSpacing: 0,
  );

  // Body Strong — 14 / 700
  static const TextStyle _titleMedium = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w700,
    color: AppColors.white,
    letterSpacing: 0,
  );

  // Body Strong (alternate slot for ergonomic usage)
  static const TextStyle _bodyLarge = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w700,
    color: AppColors.white,
    letterSpacing: 0,
  );

  // Body Regular — 12 / 600, muted
  static const TextStyle _bodyMedium = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w600,
    color: AppColors.textMuted,
    letterSpacing: 0,
  );

  // Meta / Caption — 11 / 600, muted
  static const TextStyle _bodySmall = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 11,
    fontWeight: FontWeight.w600,
    color: AppColors.textMuted,
    letterSpacing: 0,
  );

  // Section Label — 12 / 800, uppercase, dim (apply TextCapitalization in widget)
  static const TextStyle _labelLarge = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w800,
    color: AppColors.textDim,
    letterSpacing: 0.72, // ≈ 0.06 em at 12px
  );

  // Micro Label — 10 / 700, dim
  static const TextStyle _labelMedium = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 10,
    fontWeight: FontWeight.w700,
    color: AppColors.textDim,
    letterSpacing: 0,
  );

  // Micro Label small — 9 / 700, dim
  static const TextStyle _labelSmall = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 9,
    fontWeight: FontWeight.w700,
    color: AppColors.textDim,
    letterSpacing: 0,
  );

  static TextTheme buildTextTheme() {
    return const TextTheme(
      displayLarge: _displayLarge,
      displayMedium: _displayMedium,
      displaySmall: _displaySmall,
      headlineLarge: _headlineLarge,
      headlineSmall: _headlineSmall,
      titleSmall: _titleSmall,
      headlineMedium: _headlineMedium,
      titleLarge: _titleLarge,
      titleMedium: _titleMedium,
      bodyLarge: _bodyLarge,
      bodyMedium: _bodyMedium,
      bodySmall: _bodySmall,
      labelLarge: _labelLarge,
      labelMedium: _labelMedium,
      labelSmall: _labelSmall,
    );
  }
}
