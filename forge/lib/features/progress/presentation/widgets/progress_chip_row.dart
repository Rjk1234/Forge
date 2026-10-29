import 'package:flutter/material.dart';
import 'package:forge/core/theme/app_dimensions.dart';
import 'package:forge/features/progress/domain/entities/exercise_progress_data.dart';
import 'package:forge/features/progress/presentation/widgets/exercise_chip.dart';

/// Horizontally scrolling row of exercise chips.
class ProgressChipRow extends StatelessWidget {
  const ProgressChipRow({
    required this.exercises,
    required this.selectedExerciseName,
    required this.onChipTap,
    super.key,
  });

  static const double _chipGap = AppSpacing.sm;
  static const double _bottomPadding = AppSpacing.xxs;

  final List<ExerciseProgressData> exercises;
  final String selectedExerciseName;
  final ValueChanged<String> onChipTap;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.only(bottom: _bottomPadding),
      child: Row(
        children: [
          for (final exercise in exercises) ...[
            ExerciseChip(
              key: ValueKey(exercise.exerciseName),
              exerciseName: exercise.exerciseName,
              isSelected: exercise.exerciseName == selectedExerciseName,
              onTap: () => onChipTap(exercise.exerciseName),
            ),
            const SizedBox(width: _chipGap),
          ],
        ],
      ),
    );
  }
}
