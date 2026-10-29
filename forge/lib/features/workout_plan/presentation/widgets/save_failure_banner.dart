import 'package:flutter/material.dart';
import 'package:forge/core/theme/app_dimensions.dart';
import 'package:forge/core/widgets/full_width.dart';
import 'package:forge/l10n/l10n.dart';

/// Error banner shown below the app bar when a save attempt fails.
class SaveFailureBanner extends StatelessWidget {
  const SaveFailureBanner({
    required this.message,
    required this.onRetry,
    super.key,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return FullWidth(
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        color: colorScheme.errorContainer,
        child: Row(
          children: [
            Icon(Icons.error_outline, color: colorScheme.error, size: 18),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                message,
                style: textTheme.bodySmall?.copyWith(color: colorScheme.error),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            GestureDetector(
              onTap: onRetry,
              child: Text(
                context.l10n.retryButton,
                style: textTheme.labelMedium?.copyWith(
                  color: colorScheme.error,
                  decoration: TextDecoration.underline,
                  decorationColor: colorScheme.error,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
