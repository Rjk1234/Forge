import 'package:flutter/material.dart';
import 'package:forge/core/theme/app_dimensions.dart';
import 'package:forge/core/theme/app_text_extension.dart';

class ExerciseFilterChip extends StatelessWidget {
  const ExerciseFilterChip({
    required this.label,
    required this.isActive,
    required this.onTap,
    super.key,
  });

  final String label;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final textStyles = AppTextExtension.of(context);
    final colorScheme = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.mdl,
          vertical: AppSpacing.xsm,
        ),
        decoration: BoxDecoration(
          color: isActive ? colorScheme.primary : colorScheme.surface,
          borderRadius: BorderRadius.circular(AppRadius.sheet),
        ),
        child: Text(
          label,
          style: textStyles.captionStrong.copyWith(
            color: isActive
                ? colorScheme.surfaceContainerLowest
                : colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}
