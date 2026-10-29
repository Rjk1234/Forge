import 'package:flutter/material.dart';
import 'package:forge/core/theme/app_dimensions.dart';
import 'package:forge/features/workout_plan/domain/entities/plan_exercise.dart';
import 'package:forge/l10n/l10n.dart';
import 'package:forge/features/workout_plan/presentation/widgets/exercise_preview_header.dart';
import 'package:forge/features/workout_plan/presentation/widgets/exercise_preview_field_grid.dart';

/// Read-only exercise card shown on the Workout Pre-Start screen.
///
/// Omits the rest period. Uses a colored type dot instead of a text badge.
/// Layout by type:
///   weighted   → 3-col: Sets / Reps / Weight
///   timeBased  → 2-col: Sets / Duration
///   bodyweight → 2-col: Sets / Reps
class ExercisePreviewCard extends StatelessWidget {
  const ExercisePreviewCard({required this.exercise, super.key});

  final PlanExercise exercise;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final name = exercise.exerciseName.trim().isEmpty
        ? context.l10n.exerciseUnavailableName
        : exercise.exerciseName;

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(AppRadius.banner),
        border: Border.all(color: colorScheme.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ExercisePreviewHeader(
            type: exercise.type,
            name: name,
            textTheme: textTheme,
          ),
          const SizedBox(height: AppSpacing.md),
          ExercisePreviewFieldGrid(exercise: exercise),
        ],
      ),
    );
  }
}
