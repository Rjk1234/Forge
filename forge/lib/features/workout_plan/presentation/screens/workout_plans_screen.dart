import 'package:forge/features/workout_plan/presentation/screens/create_edit_workout_plan_screen.dart';
import 'package:forge/features/workout_plan/presentation/screens/plan_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:forge/core/theme/app_dimensions.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:forge/app/get_it_setup.dart';
import 'package:forge/core/navigation/workout_plans_reload_notifier.dart';
import 'package:forge/core/widgets/error_card.dart';
import 'package:forge/core/navigation/plans_route_observer.dart';
import 'package:forge/core/widgets/reload_listener.dart';
import 'package:forge/core/widgets/route_reveal_listener.dart';
import 'package:forge/features/workout_plan/application/bloc/workout_plans_bloc.dart';
import 'package:forge/features/workout_plan/application/bloc/workout_plans_event.dart';
import 'package:forge/features/workout_plan/application/bloc/workout_plans_state.dart';
import 'package:forge/features/workout_plan/presentation/widgets/plans_empty_state.dart';
import 'package:forge/features/workout_plan/presentation/widgets/plans_skeleton_list.dart';
import 'package:go_router/go_router.dart';
import 'package:forge/l10n/l10n.dart';
import 'package:forge/features/workout_plan/presentation/widgets/workout_plans_list.dart';

class WorkoutPlansScreen extends StatelessWidget {
  static const String routePath = '/plans';
  static const String routeName = 'plans';

  const WorkoutPlansScreen({super.key});

  void _onReloadRequested(BuildContext context) {
    context.read<WorkoutPlansBloc>().add(const WorkoutPlansLoadRequested());
  }

  void _navigateToPlanDetail(BuildContext context, String planId) {
    context.goNamed(
      PlanDetailScreen.routeName,
      pathParameters: {PlanDetailScreen.planIdParam: planId},
    );
  }

  @override
  Widget build(BuildContext context) {
    return RouteRevealListener(
      observer: plansRouteObserver,
      onRevealed: () => _onReloadRequested(context),
      child: ReloadListener(
        notifier: getIt<WorkoutPlansReloadNotifier>(),
        onReload: () => _onReloadRequested(context),
        child: Scaffold(
          appBar: AppBar(
            automaticallyImplyLeading: false,
            title: Text(context.l10n.workoutPlansTitle),
            actions: [
              BlocBuilder<WorkoutPlansBloc, WorkoutPlansState>(
                buildWhen: (previous, current) =>
                    (previous is WorkoutPlansPopulated) !=
                    (current is WorkoutPlansPopulated),
                builder: (context, state) {
                  if (state is WorkoutPlansPopulated) {
                    return IconButton(
                      icon: const Icon(Icons.add),
                      onPressed: () => context.push(
                        CreateEditWorkoutPlanScreen.createRoutePath,
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ],
          ),
          body: BlocBuilder<WorkoutPlansBloc, WorkoutPlansState>(
            builder: (context, state) {
              if (state is WorkoutPlansLoading ||
                  state is WorkoutPlansInitial) {
                return const PlansSkeletonList();
              }

              if (state is WorkoutPlansPopulated) {
                return WorkoutPlansList(
                  plans: state.plans,
                  onPlanTap: (planId) => _navigateToPlanDetail(context, planId),
                );
              }

              if (state is WorkoutPlansEmpty) {
                return PlansEmptyState(
                  onCreateTap: () =>
                      context.push(CreateEditWorkoutPlanScreen.createRoutePath),
                );
              }

              if (state is WorkoutPlansError) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.xl),
                    child: ErrorCard(
                      message: context.l10n.plansLoadError,
                      onRetry: () => _onReloadRequested(context),
                    ),
                  ),
                );
              }

              return const SizedBox.shrink();
            },
          ),
        ),
      ),
    );
  }
}
