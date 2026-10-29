import 'package:flutter/material.dart';
import 'package:forge/core/theme/app_dimensions.dart';
import 'package:forge/core/enums/exercise_type.dart';
import 'package:forge/core/utils/format_utils.dart';
import 'package:forge/features/workout_session/domain/entities/actual_set.dart';
import 'package:forge/l10n/l10n.dart';
import 'package:forge/core/theme/app_colors_extension.dart';
import 'package:forge/core/theme/app_text_extension.dart';

/// One logged (or skipped) set, formatted for its exercise type.
class SetPill extends StatelessWidget {
  const SetPill({required this.set, required this.exerciseType, super.key});

  static const double _radius = AppRadius.small;
  static const double _horizontalPadding = AppSpacing.sm;
  static const double _verticalPadding = AppSpacing.xs;

  final ActualSet set;
  final ExerciseType exerciseType;

  /// e.g. "8×60kg", "15 reps", "00:45" or "Skipped".
  static String labelFor(
    ActualSet set,
    ExerciseType exerciseType,
    AppLocalizations l10n,
  ) {
    if (set.skipped) return l10n.workoutSummarySkippedPill;
    return switch (exerciseType) {
      ExerciseType.weighted => l10n.setPillWeighted(
        set.repetitions ?? 0,
        _formatWeight(set.weight, l10n),
      ),
      ExerciseType.bodyweight => l10n.setPillReps(set.repetitions ?? 0),
      ExerciseType.timeBased => formatDuration(set.durationSec ?? 0),
    };
  }

  static String _formatWeight(double? weight, AppLocalizations l10n) {
    if (weight == null) return l10n.valueNotAvailable;
    return weight == weight.roundToDouble()
        ? weight.toInt().toString()
        : weight.toString();
  }

  @override
  Widget build(BuildContext context) {
    final textStyles = AppTextExtension.of(context);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final appColors = AppColorsExtension.of(context);
    final textTheme = theme.textTheme;
    final labelStyle = set.skipped
        ? textTheme.bodySmall?.copyWith(
            color: appColors.textDim,
            decoration: TextDecoration.lineThrough,
          )
        : textStyles.captionStrong.copyWith(color: colorScheme.onSurface);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: _horizontalPadding,
        vertical: _verticalPadding,
      ),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        border: Border.all(color: colorScheme.outline),
        borderRadius: BorderRadius.circular(_radius),
      ),
      child: Text(labelFor(set, exerciseType, context.l10n), style: labelStyle),
    );
  }
}
