import 'package:flutter/material.dart';
import 'package:forge/core/theme/app_dimensions.dart';
import 'package:forge/core/widgets/full_width.dart';
import 'package:forge/core/widgets/button_spinner.dart';
import 'package:forge/l10n/l10n.dart';

class CreateEditPlanFooter extends StatelessWidget {
  const CreateEditPlanFooter({
    required this.isSaving,
    required this.onSave,
    super.key,
  });

  final bool isSaving;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          AppSpacing.sm,
          AppSpacing.lg,
          AppSpacing.lg,
        ),
        child: FullWidth(
          child: ElevatedButton(
            onPressed: isSaving ? null : onSave,
            style: ElevatedButton.styleFrom(
              backgroundColor: colorScheme.primary,
              foregroundColor: colorScheme.surfaceContainerLowest,
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.banner),
              ),
            ),
            child: isSaving
                ? ButtonSpinner(
                    color: colorScheme.surfaceContainerLowest,
                    size: 20,
                  )
                : Text(
                    context.l10n.savePlanButton,
                    style: textTheme.headlineSmall?.copyWith(
                      color: colorScheme.onPrimary,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
