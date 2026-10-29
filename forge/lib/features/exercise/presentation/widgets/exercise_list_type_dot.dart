import 'package:flutter/material.dart';
import 'package:forge/core/enums/exercise_type.dart';
import 'package:forge/core/theme/app_colors_extension.dart';

class ExerciseListTypeDot extends StatelessWidget {
  const ExerciseListTypeDot({required this.type, super.key});

  final ExerciseType type;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final appColors = AppColorsExtension.of(context);

    return Container(
      width: 7,
      height: 7,
      decoration: BoxDecoration(
        color: _dotColor(colorScheme, appColors),
        shape: BoxShape.circle,
      ),
    );
  }

  Color _dotColor(ColorScheme colorScheme, AppColorsExtension appColors) =>
      switch (type) {
        ExerciseType.weighted => appColors.accentCyan,
        ExerciseType.timeBased => colorScheme.primary,
        ExerciseType.bodyweight => colorScheme.onSurfaceVariant,
      };
}
