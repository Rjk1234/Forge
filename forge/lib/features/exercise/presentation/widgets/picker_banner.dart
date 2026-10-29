import 'package:flutter/material.dart';
import 'package:forge/core/theme/app_dimensions.dart';
import 'package:forge/core/widgets/full_width.dart';
import 'package:forge/core/theme/app_colors_extension.dart';
import 'package:forge/l10n/l10n.dart';
import 'package:forge/core/theme/app_text_extension.dart';

class PickerBanner extends StatelessWidget {
  const PickerBanner({required this.planName, super.key});

  final String planName;

  @override
  Widget build(BuildContext context) {
    final textStyles = AppTextExtension.of(context);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final appColors = AppColorsExtension.of(context);
    final textTheme = theme.textTheme;

    return FullWidth(
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.smd,
        ),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest,
          border: Border(bottom: BorderSide(color: colorScheme.outline)),
        ),
        child: Row(
          children: [
            Icon(Icons.list, size: 16, color: appColors.accentCyan),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text.rich(
                TextSpan(
                  text: context.l10n.pickerBannerPrefix,
                  style: textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                  children: [
                    TextSpan(
                      text: planName,
                      style: textStyles.captionStrong.copyWith(
                        color: colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
