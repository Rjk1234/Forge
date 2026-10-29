import 'package:flutter/material.dart';
import 'package:forge/core/theme/app_dimensions.dart';

import 'package:forge/l10n/l10n.dart';
import 'package:forge/core/theme/app_colors_extension.dart';

class ProfileSuccessToast extends StatelessWidget {
  const ProfileSuccessToast({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final appColors = AppColorsExtension.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      decoration: BoxDecoration(
        color: appColors.successContainer,
        borderRadius: BorderRadius.circular(AppRadius.small),
        border: Border.all(color: appColors.successBorder),
      ),
      child: Row(
        children: [
          Icon(
            Icons.check_circle_outline_rounded,
            color: colorScheme.primary,
            size: 18,
          ),
          const SizedBox(width: AppSpacing.sm),
          Text(
            context.l10n.profileSaved,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}
