import 'package:flutter/material.dart';
import 'package:forge/core/theme/app_dimensions.dart';
import 'package:forge/core/widgets/full_width.dart';

import 'package:forge/l10n/l10n.dart';
import 'package:forge/core/theme/app_colors_extension.dart';

class ProfileSaveButton extends StatelessWidget {
  const ProfileSaveButton({
    required this.onTap,
    this.isEnabled = true,
    this.showHelper = false,
    super.key,
  });

  final VoidCallback? onTap;
  final bool isEnabled;
  final bool showHelper;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final appColors = AppColorsExtension.of(context);
    return Column(
      children: [
        FullWidth(
          child: ElevatedButton(
            onPressed: isEnabled ? onTap : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: isEnabled
                  ? colorScheme.primary
                  : colorScheme.surfaceContainerHighest,
              foregroundColor: isEnabled
                  ? colorScheme.onPrimary
                  : appColors.textDim,
              disabledBackgroundColor: colorScheme.surfaceContainerHighest,
              disabledForegroundColor: appColors.textDim,
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.mdl),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.small),
              ),
            ),
            child: Text(
              context.l10n.profileSaveChanges,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: isEnabled ? colorScheme.onPrimary : appColors.textDim,
              ),
            ),
          ),
        ),
        if (showHelper) ...[
          const SizedBox(height: AppSpacing.sm),
          Text(
            context.l10n.profileFixFields,
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.error,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );
  }
}
