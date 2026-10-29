import 'package:flutter/material.dart';
import 'package:forge/core/theme/app_dimensions.dart';
import 'package:forge/l10n/l10n.dart';
import 'package:forge/features/exercise/domain/entities/exercise.dart';
import 'package:forge/core/theme/app_colors_extension.dart';
import 'package:forge/features/exercise/presentation/widgets/exercise_picker_button.dart';
import 'package:forge/features/exercise/presentation/widgets/exercise_list_type_dot.dart';

class ExerciseListItem extends StatelessWidget {
  const ExerciseListItem({
    required this.exercise,
    required this.isPickerMode,
    this.onAddTap,
    super.key,
  });

  final Exercise exercise;
  final bool isPickerMode;
  final VoidCallback? onAddTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final appColors = AppColorsExtension.of(context);
    final textTheme = theme.textTheme;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: colorScheme.outline, width: 0.5),
        ),
      ),
      child: Row(
        children: [
          ExerciseListTypeDot(type: exercise.type),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(exercise.name, style: textTheme.bodyLarge),
                const SizedBox(height: AppSpacing.xxs),
                Text(
                  context.l10n.exerciseTypeLabel(exercise.type),
                  style: textTheme.bodySmall,
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          if (isPickerMode)
            ExercisePickerButton(onTap: onAddTap)
          else
            Icon(Icons.chevron_right, color: appColors.textDim, size: 20),
        ],
      ),
    );
  }
}
