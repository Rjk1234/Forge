import 'package:flutter/material.dart';
import 'package:forge/core/theme/app_dimensions.dart';

import 'package:forge/l10n/l10n.dart';

class ProfileLogoutRow extends StatelessWidget {
  const ProfileLogoutRow({required this.onTap, super.key});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.mdl,
        ),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(AppRadius.small),
          border: Border.all(color: colorScheme.outline),
        ),
        child: Row(
          children: [
            Icon(Icons.logout_rounded, color: colorScheme.error, size: 20),
            const SizedBox(width: AppSpacing.md),
            Text(
              context.l10n.profileLogOut,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.error,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
