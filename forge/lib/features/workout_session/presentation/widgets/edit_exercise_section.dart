import 'package:flutter/material.dart';
import 'package:forge/core/theme/app_dimensions.dart';
import 'package:forge/core/widgets/app_card.dart';
import 'package:forge/core/widgets/exercise_type_dot.dart';
import 'package:forge/features/workout_session/application/models/edit_exercise_entry.dart';
import 'package:forge/features/workout_session/application/models/edit_set_entry.dart';
import 'package:forge/features/workout_session/presentation/widgets/edit_set_row.dart';

/// A card for one exercise of the edit form, listing an [EditSetRow] per set.
class EditExerciseSection extends StatelessWidget {
  const EditExerciseSection({
    required this.exercise,
    required this.onFieldChanged,
    required this.onSkippedChanged,
    super.key,
  });

  static const double _radius = AppRadius.card;
  static const double _padding = AppSpacing.mdl;
  static const double _gap = AppSpacing.sm;
  static const double _setGap = AppSpacing.mdl;

  final EditExerciseEntry exercise;
  final void Function(int setIndex, EditSetField field, String value)
  onFieldChanged;
  final void Function(int setIndex, bool skipped) onSkippedChanged;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return AppCard(
      radius: _radius,
      padding: const EdgeInsets.all(_padding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
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
            ],
          ),
          for (var i = 0; i < exercise.sets.length; i++) ...[
            const SizedBox(height: _setGap),
            EditSetRow(
              key: ValueKey('${exercise.exerciseId}-set-$i'),
              setNumber: i + 1,
              type: exercise.type,
              entry: exercise.sets[i],
              onFieldChanged: (field, value) => onFieldChanged(i, field, value),
              onSkippedChanged: (skipped) => onSkippedChanged(i, skipped),
            ),
          ],
        ],
      ),
    );
  }
}
