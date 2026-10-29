import 'package:flutter/material.dart';
import 'package:forge/core/theme/app_dimensions.dart';
import 'package:forge/features/workout_plan/domain/entities/plan_exercise.dart';
import 'package:forge/l10n/l10n.dart';
import 'package:forge/features/workout_plan/presentation/widgets/plan_exercise_header.dart';
import 'package:forge/features/workout_plan/presentation/widgets/plan_exercise_field_grid.dart';

/// Read-only card displaying one exercise's target parameters within a plan.
///
/// Layout varies by [PlanExercise.type]:
///   - weighted:   row1(Sets + Reps + Weight) + row2 full-width(Rest)
///   - timeBased:  single row(Sets + Duration + Rest)
///   - bodyweight: single row(Sets + Reps + Rest)
class PlanExerciseDetailCard extends StatelessWidget {
  const PlanExerciseDetailCard({required this.exercise, super.key});

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
          PlanExerciseHeader(
            type: exercise.type,
            name: name,
            textTheme: textTheme,
          ),
          const SizedBox(height: AppSpacing.md),
          PlanExerciseFieldGrid(exercise: exercise),
        ],
      ),
    );
  }
}
