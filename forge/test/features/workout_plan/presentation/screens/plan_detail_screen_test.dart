import 'dart:async';

import 'package:flutter/material.dart';
import 'package:forge/features/schedule/presentation/screens/assign_schedule_screen.dart';
import 'package:forge/features/workout_plan/presentation/screens/workout_pre_start_screen.dart';
import 'package:forge/features/workout_plan/presentation/screens/create_edit_workout_plan_screen.dart';
import 'package:forge/features/workout_plan/application/bloc/plan_detail_event.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forge/core/enums/exercise_type.dart';
import 'package:forge/core/exceptions/app_exception.dart';
import 'package:forge/core/theme/app_theme.dart';
import 'package:forge/features/workout_plan/application/bloc/plan_detail_bloc.dart';
import 'package:forge/features/workout_plan/domain/entities/plan_exercise.dart';
import 'package:forge/features/workout_plan/domain/entities/workout_plan.dart';
import 'package:forge/features/workout_plan/domain/entities/workout_plan_detail.dart';
import 'package:forge/features/workout_plan/domain/repositories/workout_plan_repository.dart';
import 'package:forge/features/workout_plan/domain/usecases/get_workout_plan_by_id_usecase.dart';
import 'package:forge/features/workout_plan/presentation/screens/plan_detail_screen.dart';
import 'package:fpdart/fpdart.dart';
import 'package:go_router/go_router.dart';
import '../../../../helpers/l10n.dart';
import 'package:forge/l10n/l10n.dart';

// ---------------------------------------------------------------------------
// Fake repository
// ---------------------------------------------------------------------------

class _FakeRepo implements WorkoutPlanRepository {
  _FakeRepo({required this.getResult});

  final Either<AppException, WorkoutPlanDetail> getResult;

  @override
  Future<Either<AppException, WorkoutPlanDetail>> getPlanById(
    String id,
  ) async => getResult;

  @override
  Future<Either<AppException, List<WorkoutPlan>>> getAllPlans() async =>
      const Right([]);

  @override
  Future<Either<AppException, WorkoutPlanDetail>> savePlan(
    WorkoutPlanDetail plan,
  ) async => Right(plan);

  @override
  Future<Either<AppException, void>> deletePlan(String planId) async =>
      const Right(null);
}

/// Never resolves — keeps bloc in PlanDetailLoading.
class _HangingRepo implements WorkoutPlanRepository {
  @override
  Future<Either<AppException, WorkoutPlanDetail>> getPlanById(String id) =>
      Completer<Either<AppException, WorkoutPlanDetail>>().future;

  @override
  Future<Either<AppException, List<WorkoutPlan>>> getAllPlans() async =>
      const Right([]);

  @override
  Future<Either<AppException, WorkoutPlanDetail>> savePlan(
    WorkoutPlanDetail plan,
  ) async => Right(plan);

  @override
  Future<Either<AppException, void>> deletePlan(String planId) async =>
      const Right(null);
}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

WorkoutPlanDetail _plan({
  String id = 'plan-1',
  String name = 'Push Day',
  List<PlanExercise> exercises = const [],
}) => WorkoutPlanDetail(
  id: id,
  name: name,
  exercises: exercises,
  createdAt: DateTime(2024, 1, 1),
);

PlanExercise _weightedExercise() => const PlanExercise(
  exerciseId: 'ex-1',
  exerciseName: 'Bench Press',
  type: ExerciseType.weighted,
  targetSets: 4,
  restPeriodSec: 90,
  targetRepetitions: 8,
  targetWeight: 60.0,
);

PlanDetailBloc _blocFromRepo(WorkoutPlanRepository repo) =>
    PlanDetailBloc(getWorkoutPlanById: GetWorkoutPlanByIdUseCase(repo));

Widget _pump(
  PlanDetailBloc bloc, {
  String planId = 'plan-1',
  Map<String, WidgetBuilder> stubRoutes = const {},
  bool? shouldShowStartWorkout,
}) {
  bloc.add(
    PlanDetailLoadRequested(
      planId: planId,
      shouldShowStartWorkout: shouldShowStartWorkout,
    ),
  );
  final routes = <GoRoute>[
    GoRoute(
      path: '/plans',
      builder: (context, state) => const Scaffold(body: Text('plans')),
      routes: [
        GoRoute(
          path: ':planId',
          builder: (context, state) => BlocProvider<PlanDetailBloc>.value(
            value: bloc,
            child: PlanDetailScreen(
              planId: state.pathParameters['planId'] ?? planId,
            ),
          ),
          routes: [
            GoRoute(
              path: CreateEditWorkoutPlanScreen.editRouteSegment,
              name: CreateEditWorkoutPlanScreen.editRouteName,
              builder: (context, state) =>
                  stubRoutes['edit']?.call(context) ??
                  const Scaffold(body: Text('edit')),
            ),
            GoRoute(
              path: 'delete',
              builder: (context, state) =>
                  stubRoutes['delete']?.call(context) ??
                  const Scaffold(body: Text('delete')),
            ),
            GoRoute(
              path: WorkoutPreStartScreen.routeSegment,
              name: WorkoutPreStartScreen.routeName,
              builder: (context, state) =>
                  stubRoutes['start']?.call(context) ??
                  const Scaffold(body: Text('start')),
            ),
            GoRoute(
              path: AssignScheduleScreen.routeSegment,
              name: AssignScheduleScreen.routeName,
              builder: (context, state) =>
                  stubRoutes['schedule']?.call(context) ??
                  const Scaffold(body: Text('schedule')),
            ),
          ],
        ),
      ],
    ),
  ];

  final router = GoRouter(initialLocation: '/plans/$planId', routes: routes);

  return MaterialApp.router(
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    theme: AppTheme.darkTheme,
    routerConfig: router,
  );
}

// ---------------------------------------------------------------------------
// US1 / US2 — Loaded state (navigation)
// ---------------------------------------------------------------------------

void main() {
  group('PlanDetailScreen — loaded state', () {
    testWidgets('displays plan name', (tester) async {
      final bloc = _blocFromRepo(
        _FakeRepo(getResult: Right(_plan(name: 'Push Day'))),
      );
      await tester.pumpWidget(_pump(bloc));
      await tester.pump();
      expect(find.text('Push Day'), findsOneWidget);
    });

    testWidgets('shows exercise card for each exercise', (tester) async {
      final bloc = _blocFromRepo(
        _FakeRepo(getResult: Right(_plan(exercises: [_weightedExercise()]))),
      );
      await tester.pumpWidget(_pump(bloc));
      await tester.pump();
      expect(find.text('Bench Press'), findsOneWidget);
    });

    testWidgets('Start Workout button enabled when exercises present', (
      tester,
    ) async {
      final bloc = _blocFromRepo(
        _FakeRepo(getResult: Right(_plan(exercises: [_weightedExercise()]))),
      );
      await tester.pumpWidget(_pump(bloc));
      await tester.pump();
      final button = tester.widget<FilledButton>(
        find.widgetWithText(FilledButton, l10n.planDetailStartWorkoutButton),
      );
      expect(button.onPressed, isNotNull);
    });

    testWidgets('Start Workout is hidden when opened for another day', (
      tester,
    ) async {
      final bloc = _blocFromRepo(
        _FakeRepo(getResult: Right(_plan(exercises: [_weightedExercise()]))),
      );
      await tester.pumpWidget(_pump(bloc, shouldShowStartWorkout: false));
      await tester.pump();

      expect(find.text(l10n.planDetailStartWorkoutButton), findsNothing);
      expect(find.text(l10n.planDetailScheduleButton), findsOneWidget);
      expect(find.text('Bench Press'), findsOneWidget);
    });

    testWidgets('Start Workout button disabled when no exercises', (
      tester,
    ) async {
      final bloc = _blocFromRepo(
        _FakeRepo(getResult: Right(_plan(exercises: []))),
      );
      await tester.pumpWidget(_pump(bloc));
      await tester.pump();
      final button = tester.widget<FilledButton>(
        find.widgetWithText(FilledButton, l10n.planDetailStartWorkoutButton),
      );
      expect(button.onPressed, isNull);
    });

    testWidgets('edit icon button present', (tester) async {
      final bloc = _blocFromRepo(_FakeRepo(getResult: Right(_plan())));
      await tester.pumpWidget(_pump(bloc));
      await tester.pump();
      expect(find.byTooltip(l10n.planDetailEditTooltip), findsOneWidget);
    });

    testWidgets('delete icon button present', (tester) async {
      final bloc = _blocFromRepo(_FakeRepo(getResult: Right(_plan())));
      await tester.pumpWidget(_pump(bloc));
      await tester.pump();
      expect(find.byTooltip(l10n.planDetailDeleteTooltip), findsOneWidget);
    });

    testWidgets('back button navigates away', (tester) async {
      final bloc = _blocFromRepo(_FakeRepo(getResult: Right(_plan())));
      await tester.pumpWidget(_pump(bloc));
      await tester.pump();
      await tester.tap(find.byTooltip(l10n.planDetailBackTooltip));
      await tester.pumpAndSettle();
      expect(find.text('plans'), findsOneWidget);
    });

    testWidgets('tapping edit navigates to edit stub', (tester) async {
      final bloc = _blocFromRepo(_FakeRepo(getResult: Right(_plan())));
      await tester.pumpWidget(_pump(bloc));
      await tester.pump();
      await tester.tap(find.byTooltip(l10n.planDetailEditTooltip));
      await tester.pumpAndSettle();
      expect(find.text('edit'), findsOneWidget);
    });
  });

  // ---------------------------------------------------------------------------
  // Loading state (T016)
  // ---------------------------------------------------------------------------

  group('PlanDetailScreen — loading state', () {
    testWidgets('shows skeleton while loading', (tester) async {
      final bloc = _blocFromRepo(_HangingRepo());
      await tester.pumpWidget(_pump(bloc));
      await tester.pump();
      // Back chevron must still be accessible during loading
      expect(find.byIcon(Icons.arrow_back_ios_new), findsOneWidget);
    });

    testWidgets('edit and delete buttons absent while loading', (tester) async {
      final bloc = _blocFromRepo(_HangingRepo());
      await tester.pumpWidget(_pump(bloc));
      await tester.pump();
      expect(find.byTooltip(l10n.planDetailEditTooltip), findsNothing);
      expect(find.byTooltip(l10n.planDetailDeleteTooltip), findsNothing);
    });
  });

  // ---------------------------------------------------------------------------
  // Not-found state (T019)
  // ---------------------------------------------------------------------------

  group('PlanDetailScreen — not-found state', () {
    testWidgets('shows not-available card on PlanDetailNotFound', (
      tester,
    ) async {
      final bloc = _blocFromRepo(
        _FakeRepo(getResult: Left(CacheException(message: 'not found'))),
      );
      await tester.pumpWidget(_pump(bloc));
      await tester.pump();
      expect(find.text(l10n.planNotAvailableTitle), findsOneWidget);
    });

    testWidgets('edit and delete buttons absent on not-found', (tester) async {
      final bloc = _blocFromRepo(
        _FakeRepo(getResult: Left(CacheException(message: 'gone'))),
      );
      await tester.pumpWidget(_pump(bloc));
      await tester.pump();
      expect(find.byTooltip(l10n.planDetailEditTooltip), findsNothing);
      expect(find.byTooltip(l10n.planDetailDeleteTooltip), findsNothing);
    });

    testWidgets('"Back to Plans" button navigates back', (tester) async {
      final bloc = _blocFromRepo(
        _FakeRepo(getResult: Left(CacheException(message: 'gone'))),
      );
      await tester.pumpWidget(_pump(bloc));
      await tester.pump();
      await tester.tap(find.text(l10n.planNotAvailableButton));
      await tester.pumpAndSettle();
      expect(find.text('plans'), findsOneWidget);
    });
  });
}
