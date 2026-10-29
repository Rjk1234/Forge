import 'package:flutter/material.dart';
import 'package:forge/core/theme/app_dimensions.dart';
import 'package:forge/core/enums/exercise_type.dart';
import 'package:forge/core/theme/app_colors_extension.dart';
import 'package:forge/l10n/l10n.dart';

class ExerciseTypeBadge extends StatelessWidget {
  const ExerciseTypeBadge({required this.type, super.key});

  final ExerciseType type;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final appColors = AppColorsExtension.of(context);
    final textTheme = theme.textTheme;
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

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: 3,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Text(label, style: textTheme.labelSmall?.copyWith(color: color)),
    );
  }
}
