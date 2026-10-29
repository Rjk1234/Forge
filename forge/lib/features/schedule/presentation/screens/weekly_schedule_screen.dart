import 'package:forge/features/schedule/presentation/widgets/remove_schedule_entry_dialog.dart';
import 'package:forge/features/schedule/application/bloc/remove_schedule_entry_bloc.dart';
import 'package:forge/app/get_it_setup.dart';
import 'package:forge/core/navigation/schedule_reload_notifier.dart';
import 'package:forge/core/widgets/reload_listener.dart';
import 'package:forge/features/workout_plan/presentation/screens/workout_pre_start_route_args.dart';
import 'package:forge/features/schedule/domain/entities/weekly_schedule.dart';
import 'package:forge/features/schedule/presentation/screens/assign_schedule_screen.dart';
import 'package:forge/features/workout_plan/presentation/screens/plan_detail_screen.dart';
import 'package:forge/features/workout_plan/presentation/screens/workout_plans_screen.dart';
import 'package:forge/features/workout_plan/presentation/screens/workout_pre_start_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:forge/features/schedule/application/bloc/week_schedule_bloc.dart';
import 'package:forge/features/schedule/application/bloc/week_schedule_event.dart';
import 'package:forge/features/schedule/application/bloc/week_schedule_state.dart';
import 'package:go_router/go_router.dart';

import '../widgets/schedule_empty_state.dart';
import '../widgets/schedule_error_card.dart';
import '../widgets/schedule_skeleton_list.dart';
import '../widgets/week_schedule_list.dart';
import 'package:forge/l10n/l10n.dart';

class WeeklyScheduleScreen extends StatelessWidget {
  static const String routePath = '/schedule';
  static const String routeName = 'schedule';

  const WeeklyScheduleScreen({super.key});

  /// A day with a plan opens that plan's schedule; a free day has no plan to
  /// edit yet, so the user picks one from the Plans tab.
  Future<void> _editDay(
    BuildContext context,
    WeeklySchedule schedule,
    int weekday,
  ) async {
    final planId = schedule.days
        .firstWhere((day) => day.weekday == weekday)
        .assignedPlan
        ?.planId;
    if (planId == null) return _openPlans(context);

    await context.pushNamed(
      AssignScheduleScreen.routeName,
      pathParameters: {PlanDetailScreen.planIdParam: planId},
    );
    if (!context.mounted) return;
    context.read<WeekScheduleBloc>().add(const WeekScheduleRequested());
  }

  /// Confirms, removes that day's plan and refreshes the week.
  Future<void> _removeDay(
    BuildContext context,
    WeeklySchedule schedule,
    int weekday,
  ) async {
    final day = schedule.days.firstWhere((day) => day.weekday == weekday);
    final planName = day.assignedPlan?.planName;
    if (planName == null) return;

    await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      barrierColor: Theme.of(context).colorScheme.scrim,
      builder: (_) => BlocProvider(
        create: (_) => getIt<RemoveScheduleEntryBloc>(),
        child: RemoveScheduleEntryDialog(
          weekday: weekday,
          planName: planName,
          dayName: context.l10n.weekdayFullNames[weekday - 1],
        ),
      ),
    );
    if (!context.mounted) return;
    context.read<WeekScheduleBloc>().add(const WeekScheduleRequested());
  }

  void _openPlans(BuildContext context) =>
      context.go(WorkoutPlansScreen.routePath);

  @override
  Widget build(BuildContext context) {
    return ReloadListener(
      notifier: getIt<ScheduleReloadNotifier>(),
      onReload: () =>
          context.read<WeekScheduleBloc>().add(const WeekScheduleRequested()),
      child: _buildScaffold(context),
    );
  }

  Widget _buildScaffold(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.scheduleScreenTitle)),
      body: BlocBuilder<WeekScheduleBloc, WeekScheduleState>(
        builder: (context, state) => switch (state) {
          WeekScheduleInitial() ||
          WeekScheduleLoading() => const ScheduleSkeletonList(),
          WeekSchedulePopulated(:final schedule) => WeekScheduleList(
            schedule: schedule,
            onEditDay: (weekday) => _editDay(context, schedule, weekday),
            onRemoveDay: (weekday) => _removeDay(context, schedule, weekday),
            onStartDay: (planId, weekday) {
              context.pushNamed(
                WorkoutPreStartScreen.routeName,
                pathParameters: {PlanDetailScreen.planIdParam: planId},
                extra: WorkoutPreStartRouteArgs(scheduledWeekday: weekday),
              );
            },
          ),
          WeekScheduleEmpty() => ScheduleEmptyState(
            onScheduleTap: () => _openPlans(context),
          ),
          WeekScheduleError() => ScheduleErrorCard(
            onRetry: () => context.read<WeekScheduleBloc>().add(
              const WeekScheduleRetried(),
            ),
          ),
        },
      ),
    );
  }
}
