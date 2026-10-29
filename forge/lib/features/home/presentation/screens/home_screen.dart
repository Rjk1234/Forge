import 'package:forge/features/workout_plan/presentation/screens/plan_detail_route_args.dart';
import 'package:forge/features/workout_plan/presentation/screens/plan_detail_screen.dart';
import 'package:forge/features/workout_plan/presentation/screens/workout_pre_start_screen.dart';
import 'package:forge/features/workout_plan/presentation/screens/create_edit_workout_plan_screen.dart';
import 'package:flutter/material.dart';
import 'package:forge/core/theme/app_dimensions.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:forge/features/home/application/bloc/home_bloc.dart';
import 'package:forge/features/home/application/bloc/home_event.dart';
import 'package:forge/features/home/application/bloc/home_state.dart';
import 'package:forge/core/widgets/error_card.dart';
import 'package:forge/features/home/presentation/widgets/home_header.dart';
import 'package:forge/core/widgets/loading_indicator.dart';
import 'package:forge/features/home/presentation/widgets/home_dashboard_content.dart';
import 'package:forge/features/schedule/presentation/screens/weekly_schedule_screen.dart';
import 'package:forge/features/workout_session/presentation/screens/workout_history_detail_screen.dart';
import 'package:forge/core/navigation/home_reload_notifier.dart';
import 'package:forge/core/widgets/reload_listener.dart';
import 'package:forge/app/get_it_setup.dart';
import 'package:go_router/go_router.dart';
import 'package:forge/l10n/l10n.dart';
import 'package:forge/features/home/presentation/widgets/home_scrollable_content.dart';

class HomeScreen extends StatelessWidget {
  static const String routePath = '/';
  static const String routeName = 'home';

  const HomeScreen({super.key});

  void _reload(BuildContext context) =>
      context.read<HomeBloc>().add(const HomeLoadRequested());

  void _startWorkout(BuildContext context, String planId) => context.goNamed(
    WorkoutPreStartScreen.routeName,
    pathParameters: {PlanDetailScreen.planIdParam: planId},
  );

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return ReloadListener(
      notifier: getIt<HomeReloadNotifier>(),
      onReload: () => _reload(context),
      child: Scaffold(
        backgroundColor: colorScheme.surfaceContainerLowest,
        body: SafeArea(
          child: BlocBuilder<HomeBloc, HomeState>(
            builder: (context, state) {
              return switch (state) {
                HomeInitial() || HomeLoading() => const LoadingIndicator(),
                HomePopulated(:final snapshot) => HomeScrollableContent(
                  children: [
                    const HomeHeader(),
                    const SizedBox(height: AppSpacing.lgx),
                    HomeDashboardContent(
                      snapshot: snapshot,
                      today: DateTime.now(),
                      onStartWorkout: (planId) =>
                          _startWorkout(context, planId),
                      onViewSchedule: () =>
                          context.go(WeeklyScheduleScreen.routePath),
                      onCreatePlan: () => context.go(
                        CreateEditWorkoutPlanScreen.createRoutePath,
                      ),
                      onOpenPlan: (planId, {required isToday}) =>
                          context.pushNamed(
                            PlanDetailScreen.routeName,
                            pathParameters: {
                              PlanDetailScreen.planIdParam: planId,
                            },
                            extra: PlanDetailRouteArgs(
                              shouldShowStartWorkout: isToday,
                            ),
                          ),
                      onOpenLastWorkout: (sessionId) => context.pushNamed(
                        WorkoutHistoryDetailScreen.routeName,
                        extra: sessionId,
                      ),
                    ),
                  ],
                ),
                HomeError() => ErrorCard(
                  message: context.l10n.homeLoadError,
                  onRetry: () =>
                      context.read<HomeBloc>().add(const HomeLoadRequested()),
                ),
              };
            },
          ),
        ),
      ),
    );
  }
}
