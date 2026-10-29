import 'package:flutter/material.dart';
import 'package:forge/core/enums/exercise_type.dart';
import 'package:forge/core/theme/app_dimensions.dart';
import 'package:forge/core/theme/app_text_extension.dart';
import 'package:forge/core/utils/format_utils.dart';
import 'package:forge/features/home/domain/entities/planned_exercise.dart';
import 'package:forge/l10n/l10n.dart';

/// One numbered exercise of today's plan with its targets and type.
class ExerciseSequenceRow extends StatelessWidget {
  const ExerciseSequenceRow({
    required this.number,
    required this.exercise,
    super.key,
  });

  static const double _badgeSize = 28;

  final int number;
  final PlannedExercise exercise;

  String _details(AppLocalizations l10n) => switch (exercise.type) {
    ExerciseType.weighted => l10n.homeRowWeighted(
      exercise.sets,
      exercise.repetitions ?? 0,
      formatWeightValue(exercise.weightKg ?? 0),
    ),
    ExerciseType.bodyweight => l10n.homeRowBodyweight(
      exercise.sets,
      exercise.repetitions ?? 0,
    ),
    ExerciseType.timeBased => l10n.homeRowTimed(
      exercise.sets,
      formatDurationCompact(exercise.durationSec ?? 0),
    ),
  };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(AppRadius.card),
      ),
      child: Row(
        children: [
          _buildNumberBadge(context),
          const SizedBox(width: AppSpacing.md),
          Expanded(child: _buildNameAndTargets(context)),
          const SizedBox(width: AppSpacing.sm),
          Text(
            context.l10n.exerciseTypeLabel(exercise.type),
            style: theme.textTheme.labelSmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNumberBadge(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: _badgeSize,
      height: _badgeSize,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        shape: BoxShape.circle,
      ),
      child: Text(
        '$number',
        style: theme.textTheme.labelMedium?.copyWith(
          color: theme.colorScheme.primary,
        ),
      ),
    );
  }

  Widget _buildNameAndTargets(BuildContext context) {
    final theme = Theme.of(context);
    final textStyles = AppTextExtension.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          exercise.name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: textStyles.bodyStrong.copyWith(
            color: theme.colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: AppSpacing.xxs),
        Text(
          _details(context.l10n),
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
