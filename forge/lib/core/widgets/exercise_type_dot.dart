import 'package:flutter/material.dart';
import 'package:forge/core/enums/exercise_type.dart';
import 'package:forge/core/theme/app_colors_extension.dart';

/// Small colored dot identifying an exercise's type.
class ExerciseTypeDot extends StatelessWidget {
  const ExerciseTypeDot({required this.type, super.key});

  static const double _size = 8;

  final ExerciseType type;

  Color _color(ColorScheme colorScheme, AppColorsExtension appColors) =>
      switch (type) {
        ExerciseType.weighted => colorScheme.primary,
        ExerciseType.timeBased => appColors.accentCyan,
        ExerciseType.bodyweight => colorScheme.onSurfaceVariant,
      };

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final appColors = AppColorsExtension.of(context);

    return Container(
      width: _size,
      height: _size,
      decoration: BoxDecoration(
        color: _color(colorScheme, appColors),
        shape: BoxShape.circle,
      ),
    );
  }
}
