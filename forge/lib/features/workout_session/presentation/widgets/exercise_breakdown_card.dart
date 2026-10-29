import 'package:flutter/material.dart';
import 'package:forge/core/theme/app_dimensions.dart';
import 'package:forge/core/widgets/app_card.dart';
import 'package:forge/core/widgets/exercise_type_dot.dart';
import 'package:forge/features/workout_session/domain/entities/session_exercise.dart';
import 'package:forge/features/workout_session/domain/rules/logged_set_rules.dart';
import 'package:forge/features/workout_session/presentation/widgets/set_pill.dart';
import 'package:forge/l10n/l10n.dart';

/// Per-exercise row of the workout summary: name, logged-set count and set pills.
class ExerciseBreakdownCard extends StatelessWidget {
  const ExerciseBreakdownCard({required this.exercise, super.key});

  static const double _radius = AppRadius.card;
  static const double _horizontalPadding = AppSpacing.mdl;
  static const double _verticalPadding = AppSpacing.md;
  static const double _gap = AppSpacing.sm;

  final SessionExercise exercise;

  String _setCountLabel(AppLocalizations l10n) =>
      l10n.setCount(validLoggedSets(exercise).length);

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return AppCard(
      isFullWidth: true,
      radius: _radius,
      padding: const EdgeInsets.symmetric(
        horizontal: _horizontalPadding,
        vertical: _verticalPadding,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ExerciseTypeDot(type: exercise.type),
              const SizedBox(width: _gap),
              Expanded(
                child: Text(
                  exercise.exerciseName,
                  style: textTheme.titleMedium,
                ),
              ),
              Text(_setCountLabel(context.l10n), style: textTheme.labelMedium),
            ],
          ),
          const SizedBox(height: _gap),
          Wrap(
            spacing: _gap,
            runSpacing: _gap,
            children: [
              for (final set in exercise.actualSets)
                SetPill(set: set, exerciseType: exercise.type),
            ],
          ),
        ],
      ),
    );
  }
}
