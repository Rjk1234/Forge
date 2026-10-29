import 'package:flutter/material.dart';
import 'package:forge/core/theme/app_dimensions.dart';
import 'package:forge/core/theme/app_text_extension.dart';
import 'package:forge/core/widgets/app_card.dart';
import 'package:forge/features/home/domain/entities/today_workout.dart';
import 'package:forge/features/home/presentation/widgets/exercise_sequence_row.dart';
import 'package:forge/features/home/presentation/widgets/plan_stats_strip.dart';
import 'package:forge/l10n/l10n.dart';

/// Today's plan: summary, targets of every exercise and the Start button.
class TodayPlanCard extends StatelessWidget {
  const TodayPlanCard({
    required this.workout,
    required this.onStart,
    super.key,
  });

  final TodayWorkout workout;
  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final textStyles = AppTextExtension.of(context);

    return AppCard(
      isFullWidth: true,
      radius: AppRadius.sheet,
      padding: const EdgeInsets.all(AppSpacing.lgx),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _overline(l10n).toUpperCase(),
            style: textStyles.overline.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            workout.planName,
            style: theme.textTheme.titleLarge?.copyWith(
              color: theme.colorScheme.onSurface,
            ),
          ),
          if (workout.muscleGroups.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.xs),
            Text(
              workout.muscleGroups.join(' · '),
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
          const SizedBox(height: AppSpacing.lg),
          PlanStatsStrip(workout: workout),
          const SizedBox(height: AppSpacing.lg),
          _buildSequence(context),
          const SizedBox(height: AppSpacing.lg),
          _buildStartButton(l10n),
        ],
      ),
    );
  }

  String _overline(AppLocalizations l10n) => workout.isCompletedToday
      ? l10n.homeDoneToday
      : l10n.homePlannedForToday(workout.estimatedMinutes);

  /// A finished day offers a quieter "Do it again" so Start is not suggested.
  Widget _buildStartButton(AppLocalizations l10n) {
    final minimumSize = const Size.fromHeight(kMinTouchTarget);
    if (workout.isCompletedToday) {
      return OutlinedButton.icon(
        onPressed: onStart,
        icon: const Icon(Icons.replay_rounded),
        label: Text(l10n.homeDoItAgain),
        style: OutlinedButton.styleFrom(minimumSize: minimumSize),
      );
    }
    return FilledButton.icon(
      onPressed: onStart,
      icon: const Icon(Icons.play_arrow_rounded),
      label: Text(l10n.homeStartTodaysWorkout),
      style: FilledButton.styleFrom(minimumSize: minimumSize),
    );
  }

  Widget _buildSequence(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final textStyles = AppTextExtension.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              l10n.homeExerciseSequence.toUpperCase(),
              style: textStyles.overline.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            Text(
              l10n.homeMovementCount(workout.exerciseCount).toUpperCase(),
              style: textStyles.overline.copyWith(
                color: theme.colorScheme.primary,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        for (var i = 0; i < workout.exercises.length; i++) ...[
          if (i > 0) const SizedBox(height: AppSpacing.sm),
          ExerciseSequenceRow(number: i + 1, exercise: workout.exercises[i]),
        ],
      ],
    );
  }
}
