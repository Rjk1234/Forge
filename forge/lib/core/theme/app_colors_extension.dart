import 'package:flutter/material.dart';
import 'package:forge/core/theme/app_colors.dart';

/// App-specific colors that have no [ColorScheme] role.
///
/// Read with `AppColorsExtension.of(context)`; the standard roles (surface,
/// primary, error, outline, ...) come from `Theme.of(context).colorScheme`.
@immutable
class AppColorsExtension extends ThemeExtension<AppColorsExtension> {
  const AppColorsExtension({
    required this.textDim,
    required this.dangerBorder,
    required this.onDanger,
    required this.accentCyan,
    required this.successContainer,
    required this.successBorder,
    required this.shimmerHighlight,
    required this.restScrim,
  });

  /// The design system's dark palette.
  static const AppColorsExtension dark = AppColorsExtension(
    textDim: AppColors.textDim,
    dangerBorder: AppColors.dangerBorder,
    onDanger: AppColors.onDanger,
    accentCyan: AppColors.cyan,
    successContainer: AppColors.successFill,
    successBorder: AppColors.successBorder,
    shimmerHighlight: AppColors.shimmerDark,
    restScrim: AppColors.scrimRest,
  );

  /// Labels, timestamps and disabled text.
  final Color textDim;
  final Color dangerBorder;

  /// Text on a danger-filled surface.
  final Color onDanger;

  /// Time-based exercise accent.
  final Color accentCyan;
  final Color successContainer;
  final Color successBorder;

  /// Lighter stop of the loading shimmer.
  final Color shimmerHighlight;

  /// Scrim behind the rest timer.
  final Color restScrim;

  /// Falls back to [dark] when the ambient theme does not register the
  /// extension (for example a bare `ThemeData` in a widget test).
  static AppColorsExtension of(BuildContext context) =>
      Theme.of(context).extension<AppColorsExtension>() ?? dark;

  @override
  AppColorsExtension copyWith({
    Color? textDim,
    Color? dangerBorder,
    Color? onDanger,
    Color? accentCyan,
    Color? successContainer,
    Color? successBorder,
    Color? shimmerHighlight,
    Color? restScrim,
  }) {
    return AppColorsExtension(
      textDim: textDim ?? this.textDim,
      dangerBorder: dangerBorder ?? this.dangerBorder,
      onDanger: onDanger ?? this.onDanger,
      accentCyan: accentCyan ?? this.accentCyan,
      successContainer: successContainer ?? this.successContainer,
      successBorder: successBorder ?? this.successBorder,
      shimmerHighlight: shimmerHighlight ?? this.shimmerHighlight,
      restScrim: restScrim ?? this.restScrim,
    );
  }

  @override
  AppColorsExtension lerp(ThemeExtension<AppColorsExtension>? other, double t) {
    if (other is! AppColorsExtension) return this;
    return AppColorsExtension(
      textDim: Color.lerp(textDim, other.textDim, t)!,
      dangerBorder: Color.lerp(dangerBorder, other.dangerBorder, t)!,
      onDanger: Color.lerp(onDanger, other.onDanger, t)!,
      accentCyan: Color.lerp(accentCyan, other.accentCyan, t)!,
      successContainer: Color.lerp(
        successContainer,
        other.successContainer,
        t,
      )!,
      successBorder: Color.lerp(successBorder, other.successBorder, t)!,
      shimmerHighlight: Color.lerp(
        shimmerHighlight,
        other.shimmerHighlight,
        t,
      )!,
      restScrim: Color.lerp(restScrim, other.restScrim, t)!,
    );
  }
}
