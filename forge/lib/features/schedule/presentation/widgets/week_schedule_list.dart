import 'package:flutter/material.dart';
import 'package:forge/core/theme/app_dimensions.dart';
import 'package:forge/features/schedule/domain/entities/weekly_schedule.dart';

import 'day_row.dart';

class WeekScheduleList extends StatelessWidget {
  const WeekScheduleList({
    required this.schedule,
    required this.onEditDay,
    required this.onRemoveDay,
    required this.onStartDay,
    super.key,
  });

  final WeeklySchedule schedule;

  /// Called with weekday (1–7) when the edit icon is tapped.
  final void Function(int weekday) onEditDay;

  /// Called with weekday (1–7) when the user removes that day's plan.
  final void Function(int weekday) onRemoveDay;

  /// Called with planId and weekday when the Start button is tapped on today's row.
  final void Function(String planId, int weekday) onStartDay;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      itemCount: schedule.days.length,
      separatorBuilder: (context, index) =>
          const SizedBox(height: AppSpacing.md),
      itemBuilder: (context, index) {
        final day = schedule.days[index];
        return DayRow(
          key: ValueKey(day.weekday),
          day: day,
          onEditTap: () => onEditDay(day.weekday),
          onRemoveTap: () => onRemoveDay(day.weekday),
          onStartTap: (planId, weekday) => onStartDay(planId, weekday),
        );
      },
    );
  }
}
