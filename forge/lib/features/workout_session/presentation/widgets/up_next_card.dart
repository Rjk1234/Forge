import 'package:flutter/material.dart';
import 'package:forge/core/theme/app_dimensions.dart';
import 'package:forge/core/widgets/app_card.dart';
import 'package:forge/core/enums/exercise_type.dart';
import 'package:forge/core/utils/format_utils.dart';
import 'package:forge/features/workout_plan/workout_plan.dart';
import 'package:forge/l10n/l10n.dart';

/// Previews the set that follows the rest period.
class UpNextCard extends StatelessWidget {
  const UpNextCard({
    required this.exercise,
    required this.setNumber,
    super.key,
  });

  static const double _radius = AppRadius.card;
  static const double _padding = AppSpacing.mdl;
  static const double _rowGap = AppSpacing.xxs;

  final PlanExercise exercise;
  final int setNumber;

  /// e.g. "Target: 8 reps · 60 kg"; segments are omitted when not applicable.
  static String targetText(PlanExercise exercise, AppLocalizations l10n) {
    final reps = exercise.targetRepetitions;
    final weight = exercise.targetWeight;
    final seconds = exercise.targetDurationSec;
    final repsText = reps == null ? null : l10n.restTimerTargetReps(reps);
    final segments = switch (exercise.type) {
      ExerciseType.weighted => [
        repsText,
        weight == null
            ? null
            : l10n.restTimerTargetWeight(formatWeightValue(weight)),
      ],
      ExerciseType.bodyweight => [repsText],
      ExerciseType.timeBased => [
        seconds == null ? null : l10n.restTimerTargetDuration(seconds),
      ],
    };
    final present = segments.whereType<String>().join(
      ' ${l10n.restTimerMetaSeparator} ',
    );
    return l10n.restTimerTarget(present);
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final name = context.l10n.restTimerUpNextName(
      exercise.exerciseName,
      setNumber,
      exercise.targetSets,
    );

    return AppCard(
      isFullWidth: true,
      radius: _radius,
      padding: const EdgeInsets.all(_padding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.l10n.restTimerUpNextLabel.toUpperCase(),
            style: textTheme.labelLarge,
          ),
          const SizedBox(height: _rowGap),
          Text(name, style: textTheme.titleMedium),
          const SizedBox(height: _rowGap),
          Text(targetText(exercise, context.l10n), style: textTheme.bodyMedium),
        ],
      ),
    );
  }
}
