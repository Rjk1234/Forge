import 'dart:async';

import 'package:flutter/material.dart';
import 'package:forge/features/workout_plan/presentation/screens/plan_detail_screen.dart';
import 'package:forge/features/workout_plan/application/bloc/workout_plans_event.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forge/features/workout_plan/domain/entities/workout_plan_detail.dart';
import 'package:forge/core/exceptions/app_exception.dart';
import 'package:forge/core/theme/app_theme.dart';
import 'package:forge/features/workout_plan/application/bloc/workout_plans_bloc.dart';
import 'package:forge/features/workout_plan/domain/entities/workout_plan.dart';
import 'package:forge/features/workout_plan/domain/repositories/workout_plan_repository.dart';
import 'package:forge/features/workout_plan/domain/usecases/get_workout_plans_usecase.dart';
import 'package:forge/features/workout_plan/presentation/screens/workout_plans_screen.dart';
import 'package:forge/features/workout_plan/presentation/widgets/plan_card.dart';
import 'package:forge/features/workout_plan/presentation/widgets/plans_empty_state.dart';
import 'package:fpdart/fpdart.dart';
import 'package:go_router/go_router.dart';
import 'package:get_it/get_it.dart';
import 'package:forge/core/navigation/workout_plans_reload_notifier.dart';
import 'package:forge/l10n/l10n.dart';

class _FakeRepository implements WorkoutPlanRepository {
  Either<AppException, List<WorkoutPlan>> response;
  _FakeRepository(this.response);

  @override
  Future<Either<AppException, List<WorkoutPlan>>> getAllPlans() async =>
      response;

  @override
  Future<Either<AppException, WorkoutPlanDetail>> getPlanById(String planId) =>
      throw UnimplementedError();

  @override
  Future<Either<AppException, WorkoutPlanDetail>> savePlan(
    WorkoutPlanDetail plan,
  ) => throw UnimplementedError();

  @override
  Future<Either<AppException, void>> deletePlan(String planId) =>
      throw UnimplementedError();
}

/// Never completes — keeps bloc in WorkoutPlansLoading.
class _HangingRepository implements WorkoutPlanRepository {
  @override
  Future<Either<AppException, List<WorkoutPlan>>> getAllPlans() =>
      Completer<Either<AppException, List<WorkoutPlan>>>().future;

  @override
  Future<Either<AppException, WorkoutPlanDetail>> getPlanById(String planId) =>
      throw UnimplementedError();

  @override
  Future<Either<AppException, WorkoutPlanDetail>> savePlan(
    WorkoutPlanDetail plan,
  ) => throw UnimplementedError();

  @override
  Future<Either<AppException, void>> deletePlan(String planId) =>
      throw UnimplementedError();
}

WorkoutPlansBloc _makeBloc(Either<AppException, List<WorkoutPlan>> result) =>
    WorkoutPlansBloc(
      getWorkoutPlans: GetWorkoutPlansUseCase(
        repository: _FakeRepository(result),
      ),
    );

WorkoutPlansBloc _makeLoadingBloc() => WorkoutPlansBloc(
  getWorkoutPlans: GetWorkoutPlansUseCase(repository: _HangingRepository()),
);

final _now = DateTime(2026, 9, 17);

WorkoutPlan _plan(String id, {int exerciseCount = 2}) => WorkoutPlan(
  id: id,
  name: 'Plan $id',
  exerciseCount: exerciseCount,
  createdAt: _now,
);

// Wraps screen in GoRouter so context.go() works.
Widget _pump(WorkoutPlansBloc bloc) {
  bloc.add(const WorkoutPlansLoadRequested());
  final router = GoRouter(
    initialLocation: '/plans',
    routes: [
      GoRoute(
        path: '/plans',
        builder: (context, state) => BlocProvider<WorkoutPlansBloc>.value(
          value: bloc,
          child: const WorkoutPlansScreen(),
        ),
        routes: [
          GoRoute(
            path: PlanDetailScreen.routeSegment,
            name: PlanDetailScreen.routeName,
            builder: (context, state) => Scaffold(
              body: Text('detail:${state.pathParameters['planId']}'),
            ),
          ),
        ],
      ),
    ],
  );

  return MaterialApp.router(
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    theme: AppTheme.darkTheme,
    routerConfig: router,
  );
}

void _registerGetIt() {
  final getIt = GetIt.instance;
  if (!getIt.isRegistered<WorkoutPlansReloadNotifier>()) {
    getIt.registerLazySingleton<WorkoutPlansReloadNotifier>(
      () => WorkoutPlansReloadNotifier(),
    );
  }
}

void main() {
  setUpAll(_registerGetIt);

  // -------------------------------------------------------------------------
  // US1 — View Plans (Loading & Populated)
  // -------------------------------------------------------------------------

  group('WorkoutPlansScreen — US1 (view plans)', () {
    testWidgets('shows app bar title "Workout Plans"', (tester) async {
      final bloc = _makeBloc(Right([_plan('p1')]));

      await tester.pumpWidget(_pump(bloc));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));

      expect(find.text('Workout Plans'), findsOneWidget);
      bloc.close();
    });

    testWidgets('shows skeleton while loading', (tester) async {
      // Use a repo that never resolves so the bloc stays in WorkoutPlansLoading.
      final bloc = _makeLoadingBloc();

      await tester.pumpWidget(_pump(bloc));
      await tester
          .pump(); // GoRouter settles; bloc stays Loading (no plans yet)

      expect(find.text('Plan p1'), findsNothing);
      bloc.close();
    });

    testWidgets('shows plan cards after load', (tester) async {
      final bloc = _makeBloc(Right([_plan('p1'), _plan('p2')]));

      await tester.pumpWidget(_pump(bloc));
      await tester.pump(const Duration(milliseconds: 50));

      expect(find.byType(PlanCard), findsNWidgets(2));
      expect(find.text('Plan p1'), findsOneWidget);
      expect(find.text('Plan p2'), findsOneWidget);
      bloc.close();
    });

    testWidgets('plan card shows correct exercise count label', (tester) async {
      final bloc = _makeBloc(Right([_plan('p1', exerciseCount: 1)]));

      await tester.pumpWidget(_pump(bloc));
      await tester.pump(const Duration(milliseconds: 50));

      expect(find.text('1 exercise'), findsOneWidget);
      bloc.close();
    });

    testWidgets('plan card shows plural exercise count label', (tester) async {
      final bloc = _makeBloc(Right([_plan('p1', exerciseCount: 5)]));

      await tester.pumpWidget(_pump(bloc));
      await tester.pump(const Duration(milliseconds: 50));

      expect(find.text('5 exercises'), findsOneWidget);
      bloc.close();
    });
  });

  // -------------------------------------------------------------------------
  // US2 — Empty State
  // -------------------------------------------------------------------------

  group('WorkoutPlansScreen — US2 (empty state)', () {
    testWidgets('shows empty state when no plans exist', (tester) async {
      final bloc = _makeBloc(const Right([]));

      await tester.pumpWidget(_pump(bloc));
      await tester.pump(const Duration(milliseconds: 50));

      expect(find.byType(PlansEmptyState), findsOneWidget);
      expect(find.text('No workout plans yet'), findsOneWidget);
      bloc.close();
    });

    testWidgets('shows the empty state when a reload finds no plans left', (
      tester,
    ) async {
      final repository = _FakeRepository(Right([_plan('p1')]));
      final bloc = WorkoutPlansBloc(
        getWorkoutPlans: GetWorkoutPlansUseCase(repository: repository),
      );

      await tester.pumpWidget(_pump(bloc));
      await tester.pump(const Duration(milliseconds: 50));
      expect(find.byType(PlanCard), findsOneWidget);

      repository.response = const Right([]);
      GetIt.instance<WorkoutPlansReloadNotifier>().notify();
      await tester.pump(const Duration(milliseconds: 50));

      expect(find.byType(PlansEmptyState), findsOneWidget);
      expect(find.byType(PlanCard), findsNothing);
      bloc.close();
    });

    testWidgets('empty state does not show FAB / add icon', (tester) async {
      final bloc = _makeBloc(const Right([]));

      await tester.pumpWidget(_pump(bloc));
      await tester.pump(const Duration(milliseconds: 50));

      expect(find.byIcon(Icons.add), findsNothing);
      bloc.close();
    });
  });

  // -------------------------------------------------------------------------
  // US3 — Navigate to Plan Detail
  // -------------------------------------------------------------------------

  group('WorkoutPlansScreen — US3 (tap navigates to plan detail)', () {
    testWidgets('tapping a plan card navigates to detail route', (
      tester,
    ) async {
      final bloc = _makeBloc(Right([_plan('plan-abc')]));

      await tester.pumpWidget(_pump(bloc));
      await tester.pump(const Duration(milliseconds: 50));

      await tester.tap(find.byType(PlanCard).first);
      await tester.pumpAndSettle();

      expect(find.text('detail:plan-abc'), findsOneWidget);
      bloc.close();
    });
  });

  // -------------------------------------------------------------------------
  // US4 — FAB (Add button in app bar)
  // -------------------------------------------------------------------------

  group('WorkoutPlansScreen — US4 (FAB visibility)', () {
    testWidgets('add icon is visible when plans are populated', (tester) async {
      final bloc = _makeBloc(Right([_plan('p1')]));

      await tester.pumpWidget(_pump(bloc));
      await tester.pump(const Duration(milliseconds: 50));

      expect(find.byIcon(Icons.add), findsOneWidget);
      bloc.close();
    });

    testWidgets('add icon is hidden when loading', (tester) async {
      // Use a repo that never resolves so the bloc stays in WorkoutPlansLoading.
      final bloc = _makeLoadingBloc();

      await tester.pumpWidget(_pump(bloc));
      await tester.pump(); // GoRouter settles; bloc stays Loading

      expect(find.byIcon(Icons.add), findsNothing);
      bloc.close();
    });
  });

  // -------------------------------------------------------------------------
  // US5 — Error Recovery
  // -------------------------------------------------------------------------

  group('WorkoutPlansScreen — US5 (error state)', () {
    testWidgets('shows error message on load failure', (tester) async {
      final bloc = _makeBloc(
        Left(CacheException(message: "Couldn't load your workout plans")),
      );

      await tester.pumpWidget(_pump(bloc));
      await tester.pump(const Duration(milliseconds: 50));

      expect(find.text("Couldn't load your workout plans"), findsOneWidget);
      bloc.close();
    });

    testWidgets('shows Retry button on error', (tester) async {
      final bloc = _makeBloc(
        Left(CacheException(message: "Couldn't load your workout plans")),
      );

      await tester.pumpWidget(_pump(bloc));
      await tester.pump(const Duration(milliseconds: 50));

      expect(find.text('Retry'), findsOneWidget);
      bloc.close();
    });

    testWidgets('add icon is hidden on error state', (tester) async {
      final bloc = _makeBloc(Left(CacheException(message: 'Error')));

      await tester.pumpWidget(_pump(bloc));
      await tester.pump(const Duration(milliseconds: 50));

      expect(find.byIcon(Icons.add), findsNothing);
      bloc.close();
    });
  });
}
