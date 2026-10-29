import 'dart:async';

import 'package:flutter/material.dart';
import 'package:forge/features/home/presentation/widgets/no_plans_card.dart';
import 'package:forge/features/home/presentation/widgets/no_workout_today_card.dart';
import 'package:forge/features/home/presentation/widgets/week_strip.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forge/app/get_it_setup.dart';
import 'package:forge/core/enums/exercise_type.dart';
import 'package:forge/core/navigation/home_reload_notifier.dart';
import 'package:forge/core/exceptions/app_exception.dart';
import 'package:forge/core/theme/app_theme.dart';
import 'package:forge/features/home/application/bloc/home_bloc.dart';
import 'package:forge/features/home/application/bloc/home_event.dart';
import 'package:forge/features/home/application/usecases/get_dashboard_snapshot_usecase.dart';
import 'package:forge/features/home/domain/entities/dashboard_snapshot.dart';
import 'package:forge/features/home/domain/entities/last_workout.dart';
import 'package:forge/features/home/domain/entities/next_workout.dart';
import 'package:forge/features/home/domain/entities/planned_exercise.dart';
import 'package:forge/features/home/domain/entities/today_workout.dart';
import 'package:forge/features/home/domain/entities/week_day_status.dart';
import 'package:forge/features/home/domain/repositories/home_repository.dart';
import 'package:forge/features/home/presentation/screens/home_screen.dart';
import 'package:fpdart/fpdart.dart';
import 'package:forge/l10n/l10n.dart';

// ---------------------------------------------------------------------------
// Fake repository — returns whatever Either is passed in
// ---------------------------------------------------------------------------

class _FakeRepo implements HomeRepository {
  final Either<AppException, DashboardSnapshot> result;
  _FakeRepo(this.result);

  @override
  Future<Either<AppException, DashboardSnapshot>>
  getDashboardSnapshot() async => result;
}

HomeBloc _makeBloc(Either<AppException, DashboardSnapshot> result) => HomeBloc(
  getDashboardSnapshot: GetDashboardSnapshotUseCase(
    repository: _FakeRepo(result),
  ),
);

Widget _pump(HomeBloc bloc) {
  bloc.add(const HomeLoadRequested());
  return MaterialApp(
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    theme: AppTheme.darkTheme,
    home: BlocProvider<HomeBloc>.value(value: bloc, child: const HomeScreen()),
  );
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

final _week = [
  for (var weekday = DateTime.monday; weekday <= DateTime.sunday; weekday++)
    WeekDayStatus(
      weekday: weekday,
      state: WeekDayState.rest,
      isToday: weekday == DateTime.wednesday,
    ),
];

void main() {
  setUp(() {
    if (getIt.isRegistered<HomeReloadNotifier>()) {
      getIt.unregister<HomeReloadNotifier>();
    }
    getIt.registerSingleton<HomeReloadNotifier>(HomeReloadNotifier());
  });

  tearDown(() => getIt.unregister<HomeReloadNotifier>());

  group('HomeScreen', () {
    testWidgets('shows LoadingIndicator while loading', (tester) async {
      // Use a slow repo so the screen stays in HomeLoading during pump.
      final controller = _ControlledRepo();
      final bloc = HomeBloc(
        getDashboardSnapshot: GetDashboardSnapshotUseCase(
          repository: controller,
        ),
      );
      bloc.add(const HomeLoadRequested());

      await tester.pumpWidget(_pump(bloc));

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      controller.complete(const Right(DashboardSnapshot(hasPlans: false)));
      bloc.close();
    });

    testWidgets('with no plans the create-plan card replaces today\'s card '
        'and the rest of Home still shows', (tester) async {
      final bloc = _makeBloc(
        Right(DashboardSnapshot(hasPlans: false, weekDays: _week)),
      );

      await tester.pumpWidget(_pump(bloc));
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byType(NoPlansCard), findsOneWidget);
      expect(find.text('Create your first workout plan'), findsOneWidget);
      expect(find.byType(NoWorkoutTodayCard), findsNothing);
      expect(find.byType(WeekStrip), findsOneWidget);
      bloc.close();
    });

    testWidgets('workout day shows the plan, targets and Start button', (
      tester,
    ) async {
      final snapshot = DashboardSnapshot(
        hasPlans: true,
        todayWorkout: TodayWorkout(
          planId: 'p1',
          planName: 'Push Day',
          exerciseCount: 2,
          dominantType: ExerciseType.weighted,
          firstExerciseRestSec: 60,
          exercises: const [
            PlannedExercise(
              name: 'Bench Press',
              type: ExerciseType.weighted,
              sets: 4,
              restSec: 60,
              repetitions: 10,
              weightKg: 60,
            ),
            PlannedExercise(
              name: 'Plank',
              type: ExerciseType.timeBased,
              sets: 2,
              restSec: 30,
              durationSec: 60,
            ),
          ],
          muscleGroups: const ['Chest', 'Core'],
          estimatedMinutes: 30,
          plannedVolumeKg: 2400,
          totalSets: 6,
        ),
        weekDays: _week,
        hasSchedule: true,
      );
      final bloc = _makeBloc(Right(snapshot));

      await tester.pumpWidget(_pump(bloc));
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Push Day'), findsOneWidget);
      expect(find.text('Chest · Core'), findsOneWidget);
      expect(find.text('Bench Press'), findsOneWidget);
      expect(find.text('4 sets · 10 reps · 60 kg'), findsOneWidget);
      expect(find.text('~2,400 kg'), findsOneWidget);
      expect(find.text("Start today's workout"), findsOneWidget);
      expect(find.text('Ready for your scheduled Push Day?'), findsOneWidget);
      expect(find.text('No workout planned today'), findsNothing);
      bloc.close();
    });

    testWidgets('no plan today shows the placeholder and the next workout', (
      tester,
    ) async {
      final snapshot = DashboardSnapshot(
        hasPlans: true,
        weekDays: _week,
        hasSchedule: true,
        nextWorkout: const NextWorkout(
          weekday: DateTime.tuesday,
          planName: 'Pull Day',
        ),
      );
      final bloc = _makeBloc(Right(snapshot));

      await tester.pumpWidget(_pump(bloc));
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('No workout planned today'), findsOneWidget);
      expect(
        find.text('Your next session is Tuesday · Pull Day'),
        findsOneWidget,
      );
      expect(find.text('View schedule'), findsOneWidget);
      expect(find.text("Start today's workout"), findsNothing);
      expect(find.text('Recovery tip'), findsOneWidget);
      bloc.close();
    });

    testWidgets('nothing scheduled at all offers to schedule a plan', (
      tester,
    ) async {
      final bloc = _makeBloc(
        Right(DashboardSnapshot(hasPlans: true, weekDays: _week)),
      );

      await tester.pumpWidget(_pump(bloc));
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Nothing scheduled yet'), findsOneWidget);
      expect(find.text('Schedule a plan'), findsOneWidget);
      bloc.close();
    });

    testWidgets('shows the last workout, or a placeholder before any', (
      tester,
    ) async {
      final withLast = _makeBloc(
        Right(
          DashboardSnapshot(
            hasPlans: true,
            weekDays: _week,
            lastWorkout: LastWorkout(
              sessionId: 's1',
              planName: 'Leg Day',
              completedAt: DateTime(2026, 10, 12),
              durationSec: 3000,
              volumeKg: 4200,
            ),
          ),
        ),
      );
      await tester.pumpWidget(_pump(withLast));
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Leg Day'), findsOneWidget);
      expect(find.text('Oct 12 · 50 min · 4,200 kg'), findsOneWidget);
      expect(find.text('No workouts logged yet'), findsNothing);
      withLast.close();

      final withoutLast = _makeBloc(
        Right(DashboardSnapshot(hasPlans: true, weekDays: _week)),
      );
      await tester.pumpWidget(_pump(withoutLast));
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('No workouts logged yet'), findsOneWidget);
      withoutLast.close();
    });

    testWidgets('the week strip shows all seven days', (tester) async {
      final bloc = _makeBloc(
        Right(DashboardSnapshot(hasPlans: true, weekDays: _week)),
      );

      await tester.pumpWidget(_pump(bloc));
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('This week'), findsOneWidget);
      expect(find.text('Mon'), findsOneWidget);
      expect(find.text('Sun'), findsOneWidget);
      bloc.close();
    });

    testWidgets('shows Retry button in HomeError state', (tester) async {
      final bloc = _makeBloc(
        Left(CacheException(message: "Couldn't load your dashboard")),
      );

      await tester.pumpWidget(_pump(bloc));
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Retry'), findsOneWidget);
      expect(find.text("Couldn't load your dashboard"), findsOneWidget);
      bloc.close();
    });
  });
}

// ---------------------------------------------------------------------------
// Helper: controllable repo that holds the response until explicitly resolved
// ---------------------------------------------------------------------------

class _ControlledRepo implements HomeRepository {
  final _completer = Completer<Either<AppException, DashboardSnapshot>>();

  void complete(Either<AppException, DashboardSnapshot> result) {
    if (!_completer.isCompleted) _completer.complete(result);
  }

  @override
  Future<Either<AppException, DashboardSnapshot>> getDashboardSnapshot() =>
      _completer.future;
}
