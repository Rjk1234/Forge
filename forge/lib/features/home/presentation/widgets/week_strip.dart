import 'package:flutter/material.dart';
import 'package:forge/core/theme/app_dimensions.dart';
import 'package:forge/core/widgets/app_card.dart';
import 'package:forge/features/home/domain/entities/week_day_status.dart';
import 'package:forge/features/home/domain/rules/week_overview.dart';
import 'package:forge/features/home/presentation/widgets/week_day_cell.dart';
import 'package:forge/features/home/presentation/widgets/week_day_detail.dart';
import 'package:forge/l10n/l10n.dart';

/// Monday-to-Sunday overview: tap a day to see its plan or workout.
class WeekStrip extends StatefulWidget {
  const WeekStrip({
    required this.days,
    required this.onOpenPlan,
    required this.onOpenSession,
    required this.onOpenSchedule,
    super.key,
  });

  final List<WeekDayStatus> days;
  final void Function(String planId, {required bool isToday}) onOpenPlan;
  final void Function(String sessionId) onOpenSession;
  final VoidCallback onOpenSchedule;

  @override
  State<WeekStrip> createState() => _WeekStripState();
}

class _WeekStripState extends State<WeekStrip> {
  /// Null until the user taps a day; then today is shown.
  int? _selectedWeekday;

  WeekDayStatus get _selected {
    final weekday = _selectedWeekday;
    return widget.days.firstWhere(
      (day) => weekday == null ? day.isToday : day.weekday == weekday,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final progress = weekProgress(widget.days);
    final selected = _selected;

    return AppCard(
      isFullWidth: true,
      radius: AppRadius.sheet,
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                l10n.homeThisWeek,
                style: theme.textTheme.titleSmall?.copyWith(
                  color: theme.colorScheme.onSurface,
                ),
              ),
              if (progress.total > 0)
                Text(
                  l10n.homeWeekProgress(progress.done, progress.total),
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: theme.colorScheme.primary,
                  ),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              for (final day in widget.days)
                WeekDayCell(
                  day: day,
                  label: l10n.weekdayAbbreviations[day.weekday - 1],
                  isSelected: day.weekday == selected.weekday,
                  onTap: () => setState(() => _selectedWeekday = day.weekday),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          WeekDayDetail(
            day: selected,
            dayName: l10n.weekdayFullNames[selected.weekday - 1],
            onOpenPlan: widget.onOpenPlan,
            onOpenSession: widget.onOpenSession,
            onOpenSchedule: widget.onOpenSchedule,
          ),
        ],
      ),
    );
  }
}
