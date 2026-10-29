import 'package:flutter/material.dart';
import 'package:forge/core/theme/app_dimensions.dart';
import 'package:forge/core/widgets/full_width.dart';
import 'package:forge/features/home/domain/entities/week_day_status.dart';
import 'package:forge/l10n/l10n.dart';

/// The selected day of the week strip in words; opens its plan or workout.
class WeekDayDetail extends StatelessWidget {
  const WeekDayDetail({
    required this.day,
    required this.dayName,
    required this.onOpenPlan,
    required this.onOpenSession,
    required this.onOpenSchedule,
    super.key,
  });

  final WeekDayStatus day;
  final String dayName;
  final void Function(String planId, {required bool isToday}) onOpenPlan;
  final void Function(String sessionId) onOpenSession;

  /// Opens the schedule, for a day with no plan and no workout.
  final VoidCallback onOpenSchedule;

  String _text(AppLocalizations l10n) {
    final session = day.session;
    final plan = day.plan;
    return switch (day.state) {
      WeekDayState.completed => l10n.homeWeekDetailCompleted(
        dayName,
        session!.planName,
        session.count,
      ),
      WeekDayState.planned => l10n.homeWeekDetailPlanned(
        dayName,
        plan!.planName,
      ),
      WeekDayState.missed => l10n.homeWeekDetailMissed(dayName, plan!.planName),
      WeekDayState.rest => l10n.homeWeekDetailRest(dayName),
    };
  }

  VoidCallback _onTap() {
    final session = day.session;
    final plan = day.plan;
    if (session != null) return () => onOpenSession(session.sessionId);
    if (plan != null) {
      return () => onOpenPlan(plan.planId, isToday: day.isToday);
    }
    return onOpenSchedule;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final onTap = _onTap();

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.card),
      child: FullWidth(
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.smd,
          ),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(AppRadius.card),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  _text(context.l10n),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurface,
                  ),
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: colorScheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
