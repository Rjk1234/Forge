import 'package:flutter/material.dart';
import 'package:forge/core/theme/app_dimensions.dart';
import 'package:forge/l10n/l10n.dart';

/// Confirmation dialog shown when the user tries to leave a dirty form.
class DiscardDialog extends StatelessWidget {
  const DiscardDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return AlertDialog(
      backgroundColor: colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.banner),
      ),
      title: Text(
        context.l10n.discardChangesTitle,
        style: textTheme.titleMedium?.copyWith(color: colorScheme.onSurface),
      ),
      content: Text(
        context.l10n.discardChangesMessage,
        style: textTheme.bodyMedium?.copyWith(
          color: colorScheme.onSurfaceVariant,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(
            context.l10n.keepEditingButton,
            style: textTheme.labelLarge?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: Text(
            context.l10n.discardButton,
            style: textTheme.labelLarge?.copyWith(color: colorScheme.error),
          ),
        ),
      ],
    );
  }
}
