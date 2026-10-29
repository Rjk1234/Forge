import 'package:flutter/material.dart';
import 'package:forge/core/theme/app_dimensions.dart';
import 'package:forge/core/widgets/app_card.dart';
import 'package:forge/l10n/l10n.dart';
import 'package:forge/core/theme/app_colors_extension.dart';
import 'package:forge/core/theme/app_text_extension.dart';
import 'package:forge/features/schedule/presentation/widgets/recurrence_toggle_indicator.dart';

/// Static "Repeats weekly" display — no New/Edit visual distinction, no
/// interactive toggle.
class RecurrenceRow extends StatelessWidget {
  const RecurrenceRow({super.key});

  @override
  Widget build(BuildContext context) {
    final textStyles = AppTextExtension.of(context);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final appColors = AppColorsExtension.of(context);
    final textTheme = theme.textTheme;

    return Semantics(
      label: context.l10n.recurrenceSemantics(
        context.l10n.recurrenceWeeklyTitle,
        context.l10n.recurrenceWeeklySubtitle,
      ),
      child: AppCard(
        isFullWidth: true,
        radius: 12,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.mdl,
          vertical: 13,
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    context.l10n.recurrenceWeeklyTitle,
                    style: textStyles.bodyStrong.copyWith(
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xxs),
                  Text(
                    context.l10n.recurrenceWeeklySubtitle,
                    style: textTheme.labelSmall?.copyWith(
                      color: appColors.textDim,
                    ),
                  ),
                ],
              ),
            ),
            const RecurrenceToggleIndicator(),
          ],
        ),
      ),
    );
  }
}
