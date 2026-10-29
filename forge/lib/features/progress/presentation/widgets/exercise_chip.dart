import 'package:flutter/material.dart';
import 'package:forge/core/theme/app_dimensions.dart';
import 'package:forge/core/theme/app_text_extension.dart';

/// Pill that selects an exercise on the Progress screen.
class ExerciseChip extends StatelessWidget {
  const ExerciseChip({
    required this.exerciseName,
    required this.isSelected,
    required this.onTap,
    super.key,
  });

  static const double _horizontalPadding = AppSpacing.mdl;
  static const double _verticalPadding = AppSpacing.sm;
  static const double _maxWidth = 200;

  final String exerciseName;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final textStyles = AppTextExtension.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    final labelColor = isSelected
        ? colorScheme.onPrimary
        : colorScheme.onSurfaceVariant;

    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: _maxWidth),
      child: Material(
        color: isSelected
            ? colorScheme.primary
            : colorScheme.surfaceContainerHighest,
        shape: StadiumBorder(
          side: BorderSide(
            color: isSelected ? colorScheme.primary : colorScheme.outline,
          ),
        ),
        child: InkWell(
          customBorder: const StadiumBorder(),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: _horizontalPadding,
              vertical: _verticalPadding,
            ),
            child: Text(
              exerciseName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: textStyles.bodyStrong.copyWith(color: labelColor),
            ),
          ),
        ),
      ),
    );
  }
}
