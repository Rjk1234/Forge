import 'package:flutter/material.dart';
import 'package:forge/core/theme/app_dimensions.dart';
import 'package:forge/core/widgets/full_width.dart';
import 'package:forge/core/widgets/button_spinner.dart';
import 'package:forge/l10n/l10n.dart';
import 'package:forge/core/theme/app_colors_extension.dart';

/// Footer save button with enabled / disabled / saving / retry visual states.
class SaveScheduleButton extends StatelessWidget {
  const SaveScheduleButton({
    required this.enabled,
    required this.isSaving,
    required this.isRetry,
    required this.onPressed,
    super.key,
  });

  final bool enabled;
  final bool isSaving;
  final bool isRetry;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final appColors = AppColorsExtension.of(context);
    final textTheme = theme.textTheme;
    final label = isRetry
        ? context.l10n.retrySaveScheduleButton
        : context.l10n.saveScheduleButton;

    return SafeArea(
      top: false,
      child: FullWidth(
        child: SizedBox(
          height: 50,
          child: ElevatedButton(
            onPressed: (enabled && !isSaving) ? onPressed : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: colorScheme.primary,
              foregroundColor: colorScheme.onPrimary,
              disabledBackgroundColor: colorScheme.surfaceContainerHighest,
              disabledForegroundColor: appColors.textDim,
              padding: const EdgeInsets.symmetric(vertical: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.banner),
              ),
            ),
            child: isSaving
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ButtonSpinner(
                        color: colorScheme.onPrimary,
                        size: 18,
                        strokeWidth: 2.5,
                      ),
                      const SizedBox(width: AppSpacing.smd),
                      Text(
                        context.l10n.savingScheduleLabel,
                        style: textTheme.labelLarge?.copyWith(
                          color: colorScheme.onPrimary,
                        ),
                      ),
                    ],
                  )
                : Text(label),
          ),
        ),
      ),
    );
  }
}
