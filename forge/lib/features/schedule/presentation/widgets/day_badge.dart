import 'package:flutter/material.dart';
import 'package:forge/core/theme/app_dimensions.dart';
import 'package:forge/l10n/l10n.dart';

class DayBadge extends StatelessWidget {
  const DayBadge({
    required this.weekday,
    required this.dayNumber,
    required this.isToday,
    super.key,
  });

  /// ISO weekday: 1=Monday … 7=Sunday.
  final int weekday;
  final int dayNumber;
  final bool isToday;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final nameColor = isToday
        ? colorScheme.onPrimary
        : colorScheme.onSurfaceVariant;
    final numberColor = isToday ? colorScheme.onPrimary : colorScheme.onSurface;
    final bgColor = isToday
        ? colorScheme.primary
        : colorScheme.surfaceContainerHighest;

    return Container(
      width: 44,
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(AppRadius.small),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            context.l10n.weekdayAbbreviations[weekday - 1],
            style: textTheme.labelSmall?.copyWith(color: nameColor),
          ),
          const SizedBox(height: AppSpacing.xxs),
          Text(
            '$dayNumber',
            style: textTheme.titleSmall?.copyWith(color: numberColor),
          ),
        ],
      ),
    );
  }
}
