import 'package:flutter/material.dart';
import 'package:forge/core/theme/app_dimensions.dart';
import 'package:forge/core/theme/app_text_extension.dart';
import 'package:forge/core/widgets/app_card.dart';
import 'package:forge/l10n/l10n.dart';

/// The quote of the day.
class DailyIntentionCard extends StatelessWidget {
  const DailyIntentionCard({required this.quote, super.key});

  final String quote;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textStyles = AppTextExtension.of(context);

    return AppCard(
      isFullWidth: true,
      radius: AppRadius.sheet,
      padding: const EdgeInsets.all(AppSpacing.lgx),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.lightbulb_outline_rounded,
                size: AppIconSize.inline,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                context.l10n.homeDailyIntentionTitle.toUpperCase(),
                style: textStyles.overline.copyWith(
                  color: theme.colorScheme.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            '“$quote”',
            style: textStyles.bodyItalic.copyWith(
              color: theme.colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}
