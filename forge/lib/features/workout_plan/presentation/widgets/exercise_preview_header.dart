import 'package:flutter/material.dart';
import 'package:forge/core/theme/app_dimensions.dart';
import 'package:forge/core/enums/exercise_type.dart';
import 'package:forge/core/theme/app_colors_extension.dart';

class ExercisePreviewHeader extends StatelessWidget {
  const ExercisePreviewHeader({
    required this.type,
    required this.name,
    required this.textTheme,
    super.key,
  });

  final ExerciseType type;
  final String name;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final appColors = AppColorsExtension.of(context);
    final dotColor = switch (type) {
      ExerciseType.weighted => colorScheme.primary,
      ExerciseType.timeBased => appColors.accentCyan,
      ExerciseType.bodyweight => colorScheme.onSurfaceVariant,
    };

    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Text(
            name,
            style: textTheme.titleSmall?.copyWith(color: colorScheme.onSurface),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
