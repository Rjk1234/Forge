import 'package:flutter/material.dart';
import 'package:forge/core/theme/app_dimensions.dart';
import 'package:forge/features/schedule/domain/entities/schedule_day.dart';

import 'day_badge.dart';
import 'day_row_menu.dart';
import 'start_workout_button.dart';
import 'package:forge/l10n/l10n.dart';
import 'package:forge/core/theme/app_text_extension.dart';

class DayRow extends StatelessWidget {
  const DayRow({
    required this.day,
    required this.onEditTap,
    required this.onRemoveTap,
    required this.onStartTap,
    super.key,
  });

  final ScheduleDay day;

  /// Called for the edit icon of a free day and for "Change days" on a
  /// scheduled day.
  final VoidCallback onEditTap;

  /// Called when the user chooses to remove this day's plan.
  final VoidCallback onRemoveTap;

  /// Called when the user taps the Start button on today's row.
  final void Function(String planId, int weekday) onStartTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    final hasPlan = day.assignedPlan != null;
    final isToday = day.isToday;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.smd,
      ),
      decoration: BoxDecoration(
        color: isToday
            ? colorScheme.surfaceContainerHighest
            : colorScheme.surface,
        border: isToday
            ? Border.all(color: colorScheme.primary, width: 1.5)
            : Border.all(color: colorScheme.outline),
        borderRadius: BorderRadius.circular(AppRadius.banner),
      ),
      child: Row(
        children: [
          DayBadge(
            weekday: day.weekday,
            dayNumber: day.date.day,
            isToday: isToday,
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: _buildContent(
              context,
              context.l10n,
              textTheme,
              hasPlan,
              isToday,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          _buildTrailing(context, context.l10n, hasPlan, isToday),
        ],
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    AppLocalizations l10n,
    TextTheme textTheme,
    bool hasPlan,
    bool isToday,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    if (!hasPlan) {
      return Text(
        l10n.scheduleRestDayLabel,
        style: AppTextExtension.of(context).bodyItalic,
      );
    }

    final metaLabel = isToday
        ? l10n.scheduleTodayMeta
        : l10n.scheduleRecurrenceWeekly;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          day.assignedPlan!.planName,
          style: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurface),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: AppSpacing.xxs),
        Text(
          metaLabel,
          style: textTheme.bodySmall?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _buildTrailing(
    BuildContext context,
    AppLocalizations l10n,
    bool hasPlan,
    bool isToday,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    if (!hasPlan) {
      return SizedBox(
        width: kMinTouchTarget,
        height: kMinTouchTarget,
        child: IconButton(
          onPressed: onEditTap,
          tooltip: l10n.scheduleEditTooltip,
          icon: const Icon(Icons.edit_outlined, size: 20),
          color: colorScheme.onSurfaceVariant,
          padding: EdgeInsets.zero,
        ),
      );
    }

    final menu = DayRowMenu(onChangeDays: onEditTap, onRemove: onRemoveTap);
    if (!isToday) return menu;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        StartWorkoutButton(
          onPressed: () =>
              onStartTap(day.assignedPlan?.planId ?? '', day.weekday),
        ),
        menu,
      ],
    );
  }
}
