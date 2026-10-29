import 'package:flutter/material.dart';
import 'package:forge/core/theme/app_dimensions.dart';
import 'package:forge/core/widgets/app_card.dart';
import 'package:forge/core/widgets/app_empty_state.dart';
import 'package:forge/features/home/domain/entities/next_workout.dart';
import 'package:forge/l10n/l10n.dart';

/// Placeholder shown in place of today's plan when nothing is scheduled.
class NoWorkoutTodayCard extends StatelessWidget {
  const NoWorkoutTodayCard({
    required this.nextWorkout,
    required this.onViewSchedule,
    super.key,
  });

  /// The next scheduled session; null when nothing is scheduled at all.
  final NextWorkout? nextWorkout;
  final VoidCallback onViewSchedule;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final next = nextWorkout;

    return AppCard(
      isFullWidth: true,
      radius: AppRadius.sheet,
      child: AppEmptyState(
        icon: Icons.self_improvement,
        title: next == null
            ? l10n.homeNothingScheduledTitle
            : l10n.homeNoWorkoutTitle,
        subtitle: next == null
            ? l10n.homeNoWorkoutNoSchedule
            : l10n.homeNoWorkoutNext(
                l10n.weekdayFullNames[next.weekday - 1],
                next.planName,
              ),
        actionLabel: next == null
            ? l10n.homeScheduleAPlan
            : l10n.homeViewSchedule,
        onAction: onViewSchedule,
        layout: EmptyStateLayout.inline,
      ),
    );
  }
}
