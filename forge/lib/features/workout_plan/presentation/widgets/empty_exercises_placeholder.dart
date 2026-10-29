import 'package:flutter/material.dart';
import 'package:forge/core/theme/app_dimensions.dart';
import 'package:forge/core/theme/app_colors_extension.dart';
import 'package:forge/l10n/l10n.dart';

class EmptyExercisesPlaceholder extends StatelessWidget {
  const EmptyExercisesPlaceholder({
    required this.textTheme,
    this.errorText,
    super.key,
  });

  final TextTheme textTheme;

  /// Shown instead of the hint when saving was attempted with no exercises.
  final String? errorText;

  @override
  Widget build(BuildContext context) {
    final appColors = AppColorsExtension.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    final error = errorText;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xxl),
      child: Center(
        child: Text(
          error ?? context.l10n.noPlanExercisesMessage,
          style: textTheme.bodyMedium?.copyWith(
            color: error == null ? appColors.textDim : colorScheme.error,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
