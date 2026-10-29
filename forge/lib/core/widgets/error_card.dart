import 'package:flutter/material.dart';
import 'package:forge/core/theme/app_colors_extension.dart';
import 'package:forge/core/theme/app_dimensions.dart';
import 'package:forge/l10n/l10n.dart';

/// Centred read-failure card with a Retry action, shared by every screen.
class ErrorCard extends StatelessWidget {
  const ErrorCard({
    required this.message,
    required this.onRetry,
    this.title,
    this.retryLabel,
    this.icon = Icons.error_outline,
    this.isRetrying = false,
    super.key,
  });

  static const double _cardPadding = AppSpacing.lgx;

  final String message;
  final VoidCallback onRetry;

  /// Optional bold heading above [message].
  final String? title;

  /// Defaults to the shared "Retry" label.
  final String? retryLabel;
  final IconData icon;

  /// Disables the button while a retry is already running.
  final bool isRetrying;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final appColors = AppColorsExtension.of(context);
    final textTheme = theme.textTheme;
    final heading = title;

    return SizedBox.expand(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Container(
            padding: const EdgeInsets.all(_cardPadding),
            decoration: BoxDecoration(
              color: colorScheme.errorContainer,
              borderRadius: BorderRadius.circular(AppRadius.banner),
              border: Border.all(color: appColors.dangerBorder),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, color: colorScheme.error, size: AppIconSize.state),
                const SizedBox(height: AppSpacing.md),
                if (heading != null) ...[
                  Text(
                    heading,
                    style: textTheme.titleSmall?.copyWith(
                      color: colorScheme.onSurface,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                ],
                Text(
                  message,
                  style: textTheme.bodyMedium?.copyWith(
                    color: heading == null
                        ? colorScheme.onSurface
                        : colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: _cardPadding),
                OutlinedButton(
                  onPressed: isRetrying ? null : onRetry,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: colorScheme.error,
                    side: BorderSide(color: appColors.dangerBorder),
                    minimumSize: const Size(0, kMinTouchTarget),
                  ),
                  child: Text(retryLabel ?? context.l10n.retryButton),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
