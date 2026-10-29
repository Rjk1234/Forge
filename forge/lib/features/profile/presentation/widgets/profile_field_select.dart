import 'package:flutter/material.dart';
import 'package:forge/core/theme/app_dimensions.dart';
import 'package:forge/core/theme/app_colors_extension.dart';

class ProfileFieldSelect extends StatelessWidget {
  const ProfileFieldSelect({
    required this.value,
    required this.hint,
    required this.onTap,
    super.key,
  });

  final String value;
  final String hint;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final appColors = AppColorsExtension.of(context);
    final hasValue = value.isNotEmpty;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.mdl,
        ),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(AppRadius.small),
          border: Border.all(color: colorScheme.outline),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                hasValue ? value : hint,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: hasValue ? colorScheme.onSurface : appColors.textDim,
                ),
              ),
            ),
            Icon(
              Icons.keyboard_arrow_down_rounded,
              color: appColors.textDim,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
