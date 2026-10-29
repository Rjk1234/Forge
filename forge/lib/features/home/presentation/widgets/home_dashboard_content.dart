import 'package:flutter/material.dart';
import 'package:forge/core/theme/app_dimensions.dart';
import 'package:forge/core/utils/format_utils.dart';
import 'package:forge/features/home/domain/entities/dashboard_snapshot.dart';
import 'package:forge/features/home/domain/entities/today_workout.dart';
import 'package:forge/features/home/domain/rules/daily_content.dart';
import 'package:forge/features/home/presentation/widgets/daily_intention_card.dart';
import 'package:forge/features/home/presentation/widgets/home_date_line.dart';
import 'package:forge/features/home/presentation/widgets/home_tip_card.dart';
import 'package:forge/features/home/presentation/widgets/last_workout_card.dart';
import 'package:forge/features/home/presentation/widgets/no_plans_card.dart';
import 'package:forge/features/home/presentation/widgets/no_workout_today_card.dart';
import 'package:forge/features/home/presentation/widgets/no_workouts_logged_card.dart';
import 'package:forge/features/home/presentation/widgets/today_plan_card.dart';
import 'package:forge/features/home/presentation/widgets/week_strip.dart';
import 'package:forge/l10n/l10n.dart';

/// Everything on Home below the header: date, quote, today's plan (or the
/// create-plan / no-workout placeholder), the week, the last workout and a tip.
class HomeDashboardContent extends StatelessWidget {
  const HomeDashboardContent({
    required this.snapshot,
    required this.today,
    required this.onStartWorkout,
    required this.onViewSchedule,
    required this.onCreatePlan,
    required this.onOpenLastWorkout,
    required this.onOpenPlan,
    super.key,
  });

  final DashboardSnapshot snapshot;
  final DateTime today;
  final void Function(String planId) onStartWorkout;
  final VoidCallback onViewSchedule;
  final VoidCallback onCreatePlan;
  final void Function(String sessionId) onOpenLastWorkout;
  final void Function(String planId, {required bool isToday}) onOpenPlan;

  String _subtitle(AppLocalizations l10n, TodayWorkout? workout) =>
      workout == null
      ? l10n.homeNoPlanSubtitle
      : l10n.homeReadyForPlan(workout.planName);

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final workout = snapshot.todayWorkout;
    final lastWorkout = snapshot.lastWorkout;
    final quotes = l10n.homeQuotes;
    final recoveryTips = l10n.homeRecoveryTips;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        HomeDateLine(
          date: formatWeekdayMonthDay(today),
          subtitle: _subtitle(l10n, workout),
        ),
        const SizedBox(height: AppSpacing.lg),
        DailyIntentionCard(quote: quotes[dailyIndex(today, quotes.length)]),
        const SizedBox(height: AppSpacing.lg),
        if (!snapshot.hasPlans)
          NoPlansCard(onCreatePlan: onCreatePlan)
        else if (workout == null)
          NoWorkoutTodayCard(
            nextWorkout: snapshot.nextWorkout,
            onViewSchedule: onViewSchedule,
          )
        else
          TodayPlanCard(
            workout: workout,
            onStart: () => onStartWorkout(workout.planId),
          ),
        const SizedBox(height: AppSpacing.lg),
        WeekStrip(
          days: snapshot.weekDays,
          onOpenPlan: onOpenPlan,
          onOpenSession: onOpenLastWorkout,
          onOpenSchedule: onViewSchedule,
        ),
        const SizedBox(height: AppSpacing.lg),
        if (lastWorkout == null)
          const NoWorkoutsLoggedCard()
        else
          LastWorkoutCard(
            workout: lastWorkout,
            onTap: () => onOpenLastWorkout(lastWorkout.sessionId),
          ),
        const SizedBox(height: AppSpacing.lg),
        if (workout == null)
          HomeTipCard(
            icon: Icons.spa_outlined,
            title: l10n.homeRecoveryTitle,
            body: recoveryTips[dailyIndex(today, recoveryTips.length)],
          )
        else
          HomeTipCard(
            icon: Icons.self_improvement,
            title: l10n.homeWarmupTitle,
            body: l10n.homeWarmupTip(workout.muscleGroups),
          ),
      ],
    );
  }
}
