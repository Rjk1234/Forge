import 'package:forge/core/navigation/plans_route_observer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:forge/app/get_it_setup.dart';
import 'package:forge/features/workout_plan/application/bloc/create_edit_workout_plan_event.dart';
import 'package:forge/features/personal_bests/application/bloc/pb_event.dart';
import 'package:forge/features/home/application/bloc/home_event.dart';
import 'package:forge/features/workout_plan/application/bloc/workout_plans_event.dart';
import 'package:forge/features/workout_plan/application/bloc/plan_detail_event.dart';
import 'package:forge/features/schedule/application/bloc/assign_schedule_event.dart';
import 'package:forge/features/schedule/application/bloc/week_schedule_event.dart';
import 'package:forge/features/workout_session/application/bloc/workout_history_event.dart';
import 'package:forge/features/progress/application/bloc/progress_event.dart';
import 'package:forge/features/stats/application/bloc/stats_event.dart';
import 'package:forge/features/auth/application/cubit/app_lock_cubit.dart';
import 'package:forge/features/workout_plan/workout_plan.dart';
import 'package:forge/features/workout_session/application/bloc/active_workout_bloc.dart';
import 'package:forge/features/workout_session/application/bloc/active_workout_event.dart';
import 'package:forge/features/workout_session/application/bloc/rest_timer_args.dart';
import 'package:forge/features/workout_session/application/bloc/rest_timer_bloc.dart';
import 'package:forge/features/workout_session/application/bloc/rest_timer_event.dart';
import 'package:forge/features/workout_session/application/bloc/workout_history_bloc.dart';
import 'package:forge/features/workout_session/application/bloc/workout_history_detail_bloc.dart';
import 'package:forge/features/workout_session/application/bloc/workout_history_detail_event.dart';
import 'package:forge/features/workout_session/application/bloc/workout_summary_bloc.dart';
import 'package:forge/features/workout_session/application/bloc/workout_summary_event.dart';
import 'package:forge/features/workout_session/domain/entities/workout_session.dart';
import 'package:forge/features/workout_session/presentation/screens/cancel_workout_screen.dart';
import 'package:forge/features/workout_session/presentation/screens/rest_timer_screen.dart';
import 'package:forge/features/workout_session/application/bloc/edit_workout_session_bloc.dart';
import 'package:forge/features/workout_session/application/bloc/edit_workout_session_event.dart';
import 'package:forge/features/workout_session/presentation/screens/edit_workout_session_screen.dart';
import 'package:forge/features/workout_session/presentation/screens/workout_history_detail_screen.dart';
import 'package:forge/features/workout_session/presentation/screens/workout_history_screen.dart';
import 'package:forge/features/workout_session/presentation/screens/workout_summary_screen.dart';
import 'package:forge/features/workout_session/presentation/screens/active_workout_screen.dart';
import 'package:forge/features/auth/application/cubit/app_lock_state.dart';
import 'package:forge/features/auth/presentation/screens/login_screen.dart';
import 'package:forge/features/exercise/application/bloc/exercise_catalogue_bloc.dart';
import 'package:forge/features/exercise/application/bloc/exercise_catalogue_event.dart';
import 'package:forge/features/exercise/domain/entities/picker_context.dart';
import 'package:forge/features/exercise/presentation/screens/exercise_catalogue_screen.dart';
import 'package:forge/features/home/application/bloc/home_bloc.dart';
import 'package:forge/features/home/presentation/screens/app_shell.dart';
import 'package:forge/features/home/presentation/screens/home_screen.dart';
import 'package:forge/features/profile/application/bloc/profile_bloc.dart';
import 'package:forge/features/profile/application/bloc/profile_event.dart';
import 'package:forge/features/personal_bests/application/bloc/pb_bloc.dart';
import 'package:forge/features/personal_bests/presentation/screens/personal_bests_screen.dart';
import 'package:forge/features/progress/application/bloc/progress_bloc.dart';
import 'package:forge/features/stats/application/bloc/stats_bloc.dart';
import 'package:forge/features/stats/presentation/screens/stats_screen.dart';
import 'package:forge/features/progress/presentation/screens/progress_screen.dart';
import 'package:forge/features/profile/presentation/screens/profile_screen.dart';
import 'package:forge/features/schedule/application/bloc/assign_schedule_bloc.dart';
import 'package:forge/features/schedule/application/bloc/week_schedule_bloc.dart';
import 'package:forge/features/schedule/presentation/screens/assign_schedule_screen.dart';
import 'package:forge/features/schedule/presentation/screens/weekly_schedule_screen.dart';
import 'package:forge/features/workout_plan/application/bloc/create_edit_workout_plan_bloc.dart';
import 'package:forge/features/workout_plan/application/bloc/plan_detail_bloc.dart';
import 'package:forge/features/workout_plan/application/bloc/pre_start_bloc.dart';
import 'package:forge/features/workout_plan/application/bloc/pre_start_event.dart';
import 'package:forge/features/workout_plan/application/bloc/workout_plans_bloc.dart';
import 'package:forge/features/workout_plan/presentation/screens/create_edit_workout_plan_screen.dart';
import 'package:forge/features/workout_plan/presentation/screens/plan_detail_route_args.dart';
import 'package:forge/features/workout_plan/presentation/screens/plan_detail_screen.dart';
import 'package:forge/features/workout_plan/presentation/screens/workout_pre_start_screen.dart';
import 'package:forge/features/workout_plan/presentation/screens/workout_plans_screen.dart';
import 'package:forge/features/workout_plan/presentation/screens/workout_pre_start_route_args.dart';
import 'package:go_router/go_router.dart';

import 'go_router_refresh_stream.dart';
import 'package:forge/l10n/l10n.dart';

final _homeNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'home');
final _plansNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'plans');
final _scheduleNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'schedule');
final _historyNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'history');
final _progressNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'progress');
final _statsNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'stats');

final router = GoRouter(
  initialLocation: LoginScreen.routePath,
  refreshListenable: GoRouterRefreshStream(getIt<AppLockCubit>().stream),
  redirect: _redirect,
  routes: [..._standaloneRoutes(), _shellRoute()],
  errorBuilder: (context, state) => Scaffold(
    appBar: AppBar(title: Text(context.l10n.pageNotFoundTitle)),
    body: Center(
      child: Text(context.l10n.pageNotFoundMessage(state.uri.toString())),
    ),
  ),
);

String? _redirect(BuildContext context, GoRouterState state) {
  final cubit = getIt<AppLockCubit>();
  final locked = cubit.state.status == AppLockStatus.locked;
  final onLogin = state.matchedLocation == LoginScreen.routePath;

  if (locked && !onLogin) return LoginScreen.routePath;
  if (!locked && onLogin) return HomeScreen.routePath;
  return null;
}

List<RouteBase> _standaloneRoutes() => [
  GoRoute(
    path: LoginScreen.routePath,
    name: LoginScreen.routeName,
    builder: (context, state) => BlocProvider.value(
      value: getIt<AppLockCubit>(),
      child: const LoginScreen(),
    ),
  ),
  GoRoute(
    path: ProfileScreen.routePath,
    name: ProfileScreen.routeName,
    builder: (context, state) => BlocProvider(
      create: (_) => getIt<ProfileBloc>()..add(const ProfileLoadRequested()),
      child: const ProfileScreen(),
    ),
  ),
  GoRoute(
    path: ActiveWorkoutScreen.routePath,
    name: ActiveWorkoutScreen.routeName,
    builder: (context, state) {
      final plan = state.extra as WorkoutPlanDetail;
      return BlocProvider(
        create: (_) =>
            getIt<ActiveWorkoutBloc>()..add(ActiveWorkoutStarted(plan: plan)),
        child: const ActiveWorkoutScreen(),
      );
    },
  ),
  GoRoute(
    path: PersonalBestsScreen.routePath,
    name: PersonalBestsScreen.routeName,
    builder: (context, state) => BlocProvider(
      create: (_) => getIt<PbBloc>()..add(const PbLoadRequested()),
      child: const PersonalBestsScreen(),
    ),
  ),
  GoRoute(
    path: RestTimerScreen.routePath,
    name: RestTimerScreen.routeName,
    pageBuilder: (context, state) {
      final args = state.extra! as RestTimerArgs;
      return CustomTransitionPage<void>(
        key: state.pageKey,
        opaque: false,
        transitionsBuilder: (context, animation, _, child) =>
            FadeTransition(opacity: animation, child: child),
        child: BlocProvider(
          create: (_) =>
              getIt<RestTimerBloc>()
                ..add(RestTimerStarted(restPeriodSec: args.restPeriodSec)),
          child: RestTimerScreen(upNext: args),
        ),
      );
    },
  ),
  GoRoute(
    path: CancelWorkoutScreen.routePath,
    name: CancelWorkoutScreen.routeName,
    pageBuilder: (context, state) => CustomTransitionPage<void>(
      key: state.pageKey,
      opaque: false,
      barrierColor: Theme.of(context).colorScheme.scrim,
      transitionsBuilder: (context, animation, _, child) =>
          FadeTransition(opacity: animation, child: child),
      child: CancelWorkoutScreen(planName: state.extra as String? ?? ''),
    ),
  ),
  GoRoute(
    path: WorkoutSummaryScreen.routePath,
    name: WorkoutSummaryScreen.routeName,
    builder: (context, state) {
      final session = state.extra! as WorkoutSession;
      return BlocProvider(
        create: (_) =>
            getIt<WorkoutSummaryBloc>()
              ..add(WorkoutSummaryStarted(session: session)),
        child: const WorkoutSummaryScreen(),
      );
    },
  ),
];

StatefulShellRoute _shellRoute() => StatefulShellRoute.indexedStack(
  builder: (context, state, navigationShell) =>
      AppShell(navigationShell: navigationShell),
  branches: [
    _homeBranch(),
    _plansBranch(),
    _scheduleBranch(),
    _historyBranch(),
    _progressBranch(),
    _statsBranch(),
  ],
);

StatefulShellBranch _homeBranch() => StatefulShellBranch(
  navigatorKey: _homeNavigatorKey,
  routes: [
    GoRoute(
      path: HomeScreen.routePath,
      name: HomeScreen.routeName,
      builder: (context, state) => BlocProvider(
        create: (_) => getIt<HomeBloc>()..add(const HomeLoadRequested()),
        child: const HomeScreen(),
      ),
    ),
  ],
);

StatefulShellBranch _plansBranch() => StatefulShellBranch(
  navigatorKey: _plansNavigatorKey,
  observers: [plansRouteObserver],
  routes: [
    GoRoute(
      path: WorkoutPlansScreen.routePath,
      name: WorkoutPlansScreen.routeName,
      builder: (context, state) => BlocProvider(
        create: (_) =>
            getIt<WorkoutPlansBloc>()..add(const WorkoutPlansLoadRequested()),
        child: const WorkoutPlansScreen(),
      ),
      routes: _plansChildRoutes(),
    ),
  ],
);

StatefulShellBranch _scheduleBranch() => StatefulShellBranch(
  navigatorKey: _scheduleNavigatorKey,
  routes: [
    GoRoute(
      path: WeeklyScheduleScreen.routePath,
      name: WeeklyScheduleScreen.routeName,
      builder: (context, state) => BlocProvider(
        create: (_) =>
            getIt<WeekScheduleBloc>()..add(const WeekScheduleRequested()),
        child: const WeeklyScheduleScreen(),
      ),
    ),
  ],
);

StatefulShellBranch _historyBranch() => StatefulShellBranch(
  navigatorKey: _historyNavigatorKey,
  routes: [
    GoRoute(
      path: WorkoutHistoryScreen.routePath,
      name: WorkoutHistoryScreen.routeName,
      builder: (context, state) => BlocProvider(
        create: (_) =>
            getIt<WorkoutHistoryBloc>()
              ..add(const WorkoutHistoryLoadRequested()),
        child: const WorkoutHistoryScreen(),
      ),
      routes: [
        GoRoute(
          path: WorkoutHistoryDetailScreen.routeSegment,
          name: WorkoutHistoryDetailScreen.routeName,
          builder: (context, state) => BlocProvider(
            create: (_) => getIt<WorkoutHistoryDetailBloc>()
              ..add(
                WorkoutHistoryDetailLoadRequested(
                  sessionId: state.extra! as String,
                ),
              ),
            child: WorkoutHistoryDetailScreen(
              sessionId: state.extra! as String,
            ),
          ),
          routes: [
            GoRoute(
              path: EditWorkoutSessionScreen.routeSegment,
              name: EditWorkoutSessionScreen.routeName,
              builder: (context, state) => BlocProvider(
                create: (_) => getIt<EditWorkoutSessionBloc>()
                  ..add(
                    EditWorkoutSessionLoaded(sessionId: state.extra! as String),
                  ),
                child: EditWorkoutSessionScreen(
                  sessionId: state.extra! as String,
                ),
              ),
            ),
          ],
        ),
      ],
    ),
  ],
);

StatefulShellBranch _progressBranch() => StatefulShellBranch(
  navigatorKey: _progressNavigatorKey,
  routes: [
    GoRoute(
      path: ProgressScreen.routePath,
      name: ProgressScreen.routeName,
      builder: (context, state) => BlocProvider(
        create: (_) =>
            getIt<ProgressBloc>()..add(const ProgressLoadRequested()),
        child: const ProgressScreen(),
      ),
    ),
  ],
);

StatefulShellBranch _statsBranch() => StatefulShellBranch(
  navigatorKey: _statsNavigatorKey,
  routes: [
    GoRoute(
      path: StatsScreen.routePath,
      name: StatsScreen.routeName,
      builder: (context, state) => BlocProvider(
        create: (_) => getIt<StatsBloc>()..add(const StatsLoadRequested()),
        child: const StatsScreen(),
      ),
    ),
  ],
);

List<RouteBase> _planDetailRoutes() => [
  GoRoute(
    path: CreateEditWorkoutPlanScreen.editRouteSegment,
    name: CreateEditWorkoutPlanScreen.editRouteName,
    builder: (context, state) => BlocProvider(
      create: (_) => getIt<CreateEditWorkoutPlanBloc>()
        ..add(
          CreateEditPlanInitialized(
            planId: state.pathParameters[PlanDetailScreen.planIdParam],
          ),
        ),
      child: CreateEditWorkoutPlanScreen(
        planId: state.pathParameters[PlanDetailScreen.planIdParam],
      ),
    ),
  ),
  GoRoute(
    path: AssignScheduleScreen.routeSegment,
    name: AssignScheduleScreen.routeName,
    builder: (context, state) => BlocProvider(
      create: (_) => getIt<AssignScheduleBloc>()
        ..add(
          AssignScheduleInitialized(
            state.pathParameters[PlanDetailScreen.planIdParam]!,
          ),
        ),
      child: const AssignScheduleScreen(),
    ),
  ),
  GoRoute(
    path: WorkoutPreStartScreen.routeSegment,
    name: WorkoutPreStartScreen.routeName,
    builder: (context, state) {
      final planId = state.pathParameters[PlanDetailScreen.planIdParam]!;
      final args = state.extra as WorkoutPreStartRouteArgs?;
      final weekday = args?.scheduledWeekday;
      return BlocProvider(
        create: (_) => getIt<PreStartBloc>()
          ..add(PreStartRequested(planId: planId, scheduledWeekday: weekday)),
        child: WorkoutPreStartScreen(planId: planId, scheduledWeekday: weekday),
      );
    },
  ),
];

List<RouteBase> _plansChildRoutes() => [
  GoRoute(
    path: CreateEditWorkoutPlanScreen.createRouteSegment,
    name: CreateEditWorkoutPlanScreen.createRouteName,
    builder: (context, state) => BlocProvider(
      create: (_) =>
          getIt<CreateEditWorkoutPlanBloc>()
            ..add(const CreateEditPlanInitialized()),
      child: const CreateEditWorkoutPlanScreen(),
    ),
  ),
  // Must precede ':planId', which would otherwise capture
  // '/plans/exercises' as a plan id.
  GoRoute(
    path: ExerciseCatalogueScreen.routeSegment,
    name: ExerciseCatalogueScreen.routeName,
    builder: (context, state) => BlocProvider(
      create: (_) =>
          getIt<ExerciseCatalogueBloc>()
            ..add(const ExerciseCatalogueLoadRequested()),
      child: ExerciseCatalogueScreen(
        pickerContext: state.extra as PickerContext?,
      ),
    ),
  ),
  GoRoute(
    path: PlanDetailScreen.routeSegment,
    name: PlanDetailScreen.routeName,
    builder: (context, state) => BlocProvider(
      create: (_) => getIt<PlanDetailBloc>()
        ..add(
          PlanDetailLoadRequested(
            planId: state.pathParameters[PlanDetailScreen.planIdParam] ?? '',
            shouldShowStartWorkout:
                (state.extra as PlanDetailRouteArgs?)?.shouldShowStartWorkout,
          ),
        ),
      child: PlanDetailScreen(
        planId: state.pathParameters[PlanDetailScreen.planIdParam] ?? '',
      ),
    ),
    routes: _planDetailRoutes(),
  ),
];
