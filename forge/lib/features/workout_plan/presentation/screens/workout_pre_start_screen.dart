import 'package:forge/features/workout_plan/presentation/screens/plan_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:forge/features/workout_plan/application/bloc/pre_start_bloc.dart';
import 'package:forge/features/workout_plan/application/bloc/pre_start_event.dart';
import 'package:forge/features/workout_plan/application/bloc/pre_start_state.dart';
import 'package:forge/features/workout_plan/presentation/widgets/pre_start_error_state.dart';
import 'package:forge/features/workout_plan/presentation/widgets/pre_start_skeleton.dart';
import 'package:forge/features/workout_plan/presentation/widgets/pre_start_unavailable_state.dart';
import 'package:go_router/go_router.dart';
import 'package:forge/l10n/l10n.dart';
import 'package:forge/features/workout_plan/presentation/widgets/pre_start_loaded_view.dart';

class WorkoutPreStartScreen extends StatelessWidget {
  static const String routeSegment = 'start';
  static const String routePath = '${PlanDetailScreen.routePath}/$routeSegment';
  static const String routeName = 'workoutPreStart';

  const WorkoutPreStartScreen({
    required this.planId,
    this.scheduledWeekday,
    super.key,
  });

  final String planId;
  final int? scheduledWeekday;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return BlocBuilder<PreStartBloc, PreStartState>(
      builder: (context, state) {
        return switch (state) {
          PreStartInitial() || PreStartLoading() => Scaffold(
            backgroundColor: colorScheme.surfaceContainerLowest,
            body: const PreStartSkeleton(),
          ),
          PreStartLoaded(
            :final plan,
            :final scheduledWeekday,
            :final isScheduledForToday,
            :final isCompletedToday,
          ) =>
            PreStartLoadedView(
              plan: plan,
              scheduledWeekday: scheduledWeekday,
              isScheduledForToday: isScheduledForToday,
              planId: planId,
              isCompletedToday: isCompletedToday,
            ),
          PreStartUnavailable() => Scaffold(
            backgroundColor: colorScheme.surfaceContainerLowest,
            appBar: AppBar(
              title: Text(context.l10n.preStartScreenTitle),
              backgroundColor: colorScheme.surfaceContainerLowest,
            ),
            body: PreStartUnavailableState(
              onBack: () {
                if (context.canPop()) context.pop();
              },
            ),
          ),
          PreStartError() => Scaffold(
            backgroundColor: colorScheme.surfaceContainerLowest,
            appBar: AppBar(
              title: Text(context.l10n.preStartScreenTitle),
              backgroundColor: colorScheme.surfaceContainerLowest,
            ),
            body: PreStartErrorState(
              onRetry: () => context.read<PreStartBloc>().add(
                PreStartRetried(
                  planId: planId,
                  scheduledWeekday: scheduledWeekday,
                ),
              ),
            ),
          ),
        };
      },
    );
  }
}
