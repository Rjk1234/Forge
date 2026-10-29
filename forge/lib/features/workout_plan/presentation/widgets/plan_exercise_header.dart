import 'package:flutter/material.dart';
import 'package:forge/core/theme/app_dimensions.dart';
import 'package:forge/core/enums/exercise_type.dart';
import 'package:forge/core/theme/app_colors_extension.dart';
import 'package:forge/l10n/l10n.dart';

class PlanExerciseHeader extends StatelessWidget {
  const PlanExerciseHeader({
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
    final (label, color) = switch (type) {
      ExerciseType.weighted => (
        context.l10n.exerciseTypeBadgeWeighted,
        appColors.accentCyan,
      ),
      ExerciseType.timeBased => (
        context.l10n.exerciseTypeBadgeTimeBased,
        colorScheme.primary,
      ),
      ExerciseType.bodyweight => (
        context.l10n.exerciseTypeBadgeBodyweight,
        colorScheme.onSurfaceVariant,
      ),
    };

    return Row(
      children: [
        Container(
          width: 7,
          height: 7,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: AppSpacing.xsm),
        Text(label, style: textTheme.labelSmall?.copyWith(color: color)),
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
