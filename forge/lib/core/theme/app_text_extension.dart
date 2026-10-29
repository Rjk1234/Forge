import 'package:flutter/material.dart';
import 'package:forge/core/theme/app_colors.dart';

/// Text styles that have no natural [TextTheme] slot.
///
/// Read with `AppTextExtension.of(context)`; the main type scale comes from
/// `Theme.of(context).textTheme`.
@immutable
class AppTextExtension extends ThemeExtension<AppTextExtension> {
  const AppTextExtension({
    required this.bodyRelaxed,
    required this.bodyItalic,
    required this.bodyRelaxedLarge,
    required this.bodyStrong,
    required this.captionStrong,
    required this.valueSmall,
    required this.buttonLabel,
    required this.overline,
  });

  static const String _fontFamily = 'Helvetica Neue';

  /// The design system's type styles.
  static const AppTextExtension dark = AppTextExtension(
    // Multi-line supporting copy — 13 / 600, 1.5 line height
    bodyRelaxed: TextStyle(
      fontFamily: _fontFamily,
      fontSize: 13,
      fontWeight: FontWeight.w600,
      height: 1.5,
      color: AppColors.textMuted,
    ),
    // Larger multi-line supporting copy — 14 / 600, 1.5 line height
    bodyRelaxedLarge: TextStyle(
      fontFamily: _fontFamily,
      fontSize: 14,
      fontWeight: FontWeight.w600,
      height: 1.5,
      color: AppColors.textMuted,
    ),
    // Placeholder body — 12 / 600 italic
    bodyItalic: TextStyle(
      fontFamily: _fontFamily,
      fontSize: 12,
      fontWeight: FontWeight.w600,
      fontStyle: FontStyle.italic,
      color: AppColors.textDim,
    ),
    // Emphasised body — 12 / 700
    bodyStrong: TextStyle(
      fontFamily: _fontFamily,
      fontSize: 12,
      fontWeight: FontWeight.w700,
      color: AppColors.white,
    ),
    // Emphasised caption — 11 / 700
    captionStrong: TextStyle(
      fontFamily: _fontFamily,
      fontSize: 11,
      fontWeight: FontWeight.w700,
      color: AppColors.white,
    ),
    // Compact value — 13 / 800
    valueSmall: TextStyle(
      fontFamily: _fontFamily,
      fontSize: 13,
      fontWeight: FontWeight.w800,
      color: AppColors.white,
    ),
    // Button label — 13 / 800
    buttonLabel: TextStyle(
      fontFamily: _fontFamily,
      fontSize: 13,
      fontWeight: FontWeight.w800,
      color: AppColors.white,
      letterSpacing: 0,
    ),
    // Small uppercase group label — 9 / 700, wide tracking
    overline: TextStyle(
      fontFamily: _fontFamily,
      fontSize: 9,
      fontWeight: FontWeight.w700,
      color: AppColors.textDim,
      letterSpacing: 1.2,
    ),
  );

  final TextStyle bodyRelaxed;
  final TextStyle bodyItalic;
  final TextStyle bodyRelaxedLarge;
  final TextStyle bodyStrong;
  final TextStyle captionStrong;
  final TextStyle valueSmall;
  final TextStyle buttonLabel;
  final TextStyle overline;

  /// Falls back to [dark] when the ambient theme does not register the
  /// extension (for example a bare `ThemeData` in a widget test).
  static AppTextExtension of(BuildContext context) =>
      Theme.of(context).extension<AppTextExtension>() ?? dark;

  @override
  AppTextExtension copyWith({
    TextStyle? bodyRelaxed,
    TextStyle? bodyItalic,
    TextStyle? bodyRelaxedLarge,
    TextStyle? bodyStrong,
    TextStyle? captionStrong,
    TextStyle? valueSmall,
    TextStyle? buttonLabel,
    TextStyle? overline,
  }) {
    return AppTextExtension(
      bodyRelaxed: bodyRelaxed ?? this.bodyRelaxed,
      bodyItalic: bodyItalic ?? this.bodyItalic,
      bodyRelaxedLarge: bodyRelaxedLarge ?? this.bodyRelaxedLarge,
      bodyStrong: bodyStrong ?? this.bodyStrong,
      captionStrong: captionStrong ?? this.captionStrong,
      valueSmall: valueSmall ?? this.valueSmall,
      buttonLabel: buttonLabel ?? this.buttonLabel,
      overline: overline ?? this.overline,
    );
  }

  @override
  AppTextExtension lerp(ThemeExtension<AppTextExtension>? other, double t) {
    if (other is! AppTextExtension) return this;
    return AppTextExtension(
      bodyRelaxed: TextStyle.lerp(bodyRelaxed, other.bodyRelaxed, t)!,
      bodyItalic: TextStyle.lerp(bodyItalic, other.bodyItalic, t)!,
      bodyRelaxedLarge: TextStyle.lerp(
        bodyRelaxedLarge,
        other.bodyRelaxedLarge,
        t,
      )!,
      bodyStrong: TextStyle.lerp(bodyStrong, other.bodyStrong, t)!,
      captionStrong: TextStyle.lerp(captionStrong, other.captionStrong, t)!,
      valueSmall: TextStyle.lerp(valueSmall, other.valueSmall, t)!,
      buttonLabel: TextStyle.lerp(buttonLabel, other.buttonLabel, t)!,
      overline: TextStyle.lerp(overline, other.overline, t)!,
    );
  }
}
