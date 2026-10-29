import 'package:flutter/material.dart';
import 'package:forge/core/theme/app_dimensions.dart';
import 'package:forge/l10n/l10n.dart';

/// Asks whether to start a plan again after it was already completed today.
/// Pops `true` to start anyway and `false` to go back.
class StartAgainDialog extends StatelessWidget {
  const StartAgainDialog({required this.planName, super.key});

  final String planName;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return AlertDialog(
      backgroundColor: colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.banner),
      ),
      title: Text(
        l10n.startAgainTitle,
        style: textTheme.titleMedium?.copyWith(color: colorScheme.onSurface),
      ),
      content: Text(
        l10n.startAgainMessage(planName),
        style: textTheme.bodyMedium?.copyWith(
          color: colorScheme.onSurfaceVariant,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(
            l10n.startAgainCancel,
            style: textTheme.labelLarge?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: Text(
            l10n.startAgainConfirm,
            style: textTheme.labelLarge?.copyWith(color: colorScheme.primary),
          ),
        ),
      ],
    );
  }
}
