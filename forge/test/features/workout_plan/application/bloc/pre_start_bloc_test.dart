import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forge/core/enums/exercise_type.dart';
import 'package:forge/core/exceptions/app_exception.dart';
import 'package:forge/features/workout_plan/application/bloc/pre_start_bloc.dart';
import 'package:forge/features/workout_plan/application/bloc/pre_start_event.dart';
import 'package:forge/features/workout_plan/application/bloc/pre_start_state.dart';
import 'package:forge/features/workout_plan/domain/entities/plan_exercise.dart';
import 'package:forge/features/workout_plan/domain/entities/workout_plan.dart';
import 'package:forge/features/workout_plan/domain/entities/workout_plan_detail.dart';
import 'package:forge/features/workout_plan/domain/repositories/workout_plan_repository.dart';
import 'package:forge/features/workout_plan/domain/usecases/get_workout_plan_by_id_usecase.dart';
import 'package:forge/features/workout_session/domain/repositories/workout_session_repository.dart';
import 'package:forge/features/workout_session/domain/usecases/has_completed_workout_today_usecase.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/session_builders.dart';

// ---------------------------------------------------------------------------
// Fake repository
// ---------------------------------------------------------------------------

class _FakeRepo implements WorkoutPlanRepository {
  _FakeRepo({required this.getResult});

  final Either<AppException, WorkoutPlanDetail> getResult;

  @override
  Future<Either<AppException, List<WorkoutPlan>>> getAllPlans() async =>
      const Right([]);

  @override
  Future<Either<AppException, WorkoutPlanDetail>> getPlanById(
    String planId,
  ) async => getResult;

  @override
  Future<Either<AppException, WorkoutPlanDetail>> savePlan(
    WorkoutPlanDetail plan,
  ) async => Right(plan);

  @override
  Future<Either<AppException, void>> deletePlan(String planId) async =>
      const Right(null);
}

WorkoutPlanDetail _planWithExercises({String id = 'p1'}) => WorkoutPlanDetail(
  id: id,
  name: 'Push Day',
  createdAt: DateTime(2024, 1, 1),
  exercises: const [
    PlanExercise(
      exerciseId: 'ex-1',
      exerciseName: 'Bench Press',
      type: ExerciseType.weighted,
      targetSets: 4,
      restPeriodSec: 90,
      targetRepetitions: 8,
      targetWeight: 60.0,
    ),
  ],
);

WorkoutPlanDetail _planWithNoExercises() => WorkoutPlanDetail(
  id: 'p1',
  name: 'Empty Plan',
  createdAt: DateTime(2024, 1, 1),
  exercises: const [],
);

class _HangingRepo implements WorkoutPlanRepository {
  @override
  Future<Either<AppException, WorkoutPlanDetail>> getPlanById(String planId) =>
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

class _MockSessionRepository extends Mock implements WorkoutSessionRepository {}

HasCompletedWorkoutTodayUseCase _completedToday({
  bool isDone = false,
  bool fails = false,
}) {
  final sessions = _MockSessionRepository();
  when(() => sessions.getSessionsByPlanId(any())).thenAnswer(
    (_) async => fails
        ? Left(CacheException(message: 'boom'))
        : Right([
            if (isDone) sessionOf(planId: 'p1', startedAt: DateTime.now()),
          ]),
  );
  return HasCompletedWorkoutTodayUseCase(sessions);
}

PreStartBloc _makeBloc(
  Either<AppException, WorkoutPlanDetail> result, {
  bool isDone = false,
  bool lookupFails = false,
}) {
  final repo = _FakeRepo(getResult: result);
  return PreStartBloc(
    getWorkoutPlanById: GetWorkoutPlanByIdUseCase(repo),
    hasCompletedWorkoutToday: _completedToday(
      isDone: isDone,
      fails: lookupFails,
    ),
  );
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  group('PreStartBloc done-today lookup', () {
    PreStartLoaded loadedOf(PreStartBloc bloc) => bloc.state as PreStartLoaded;

    Future<PreStartBloc> loaded({
      bool isDone = false,
      bool fails = false,
    }) async {
      final bloc = _makeBloc(
        Right(_planWithExercises()),
        isDone: isDone,
        lookupFails: fails,
      )..add(const PreStartRequested(planId: 'p1'));
      await bloc.stream.firstWhere((state) => state is PreStartLoaded);
      return bloc;
    }

    test('flags a plan already completed today', () async {
      final bloc = await loaded(isDone: true);
      expect(loadedOf(bloc).isCompletedToday, isTrue);
      await bloc.close();
    });

    test('does not flag a plan that was not completed today', () async {
      final bloc = await loaded();
      expect(loadedOf(bloc).isCompletedToday, isFalse);
      await bloc.close();
    });

    test('a failed lookup never blocks starting', () async {
      final bloc = await loaded(fails: true);
      expect(loadedOf(bloc).isCompletedToday, isFalse);
      await bloc.close();
    });
  });

  group('PreStartBloc', () {
    test('initial state is PreStartInitial', () {
      final bloc = _makeBloc(Right(_planWithExercises()));
      expect(bloc.state, isA<PreStartInitial>());
      bloc.close();
    });

    blocTest<PreStartBloc, PreStartState>(
      'PreStartRequested emits [Loading, Loaded] on success with exercises',
      build: () => _makeBloc(Right(_planWithExercises())),
      act: (bloc) => bloc.add(
        const PreStartRequested(planId: 'p1', scheduledWeekday: null),
      ),
      expect: () => [isA<PreStartLoading>(), isA<PreStartLoaded>()],
    );

    blocTest<PreStartBloc, PreStartState>(
      'PreStartLoaded carries correct plan and isScheduledForToday=false when weekday is null',
      build: () => _makeBloc(Right(_planWithExercises())),
      act: (bloc) => bloc.add(
        const PreStartRequested(planId: 'p1', scheduledWeekday: null),
      ),
      expect: () => [
        isA<PreStartLoading>(),
        isA<PreStartLoaded>()
            .having((s) => s.scheduledWeekday, 'scheduledWeekday', isNull)
            .having(
              (s) => s.isScheduledForToday,
              'isScheduledForToday',
              isFalse,
            )
            .having((s) => s.plan.name, 'plan.name', 'Push Day'),
      ],
    );

    blocTest<PreStartBloc, PreStartState>(
      'PreStartRequested emits [Loading, Unavailable] when plan has no exercises',
      build: () => _makeBloc(Right(_planWithNoExercises())),
      act: (bloc) => bloc.add(
        const PreStartRequested(planId: 'p1', scheduledWeekday: null),
      ),
      expect: () => [isA<PreStartLoading>(), isA<PreStartUnavailable>()],
    );

    blocTest<PreStartBloc, PreStartState>(
      'PreStartRequested emits [Loading, Error] on repository failure',
      build: () => _makeBloc(
        Left(
          CacheException(message: 'database error', originalException: null),
        ),
      ),
      act: (bloc) => bloc.add(
        const PreStartRequested(planId: 'p1', scheduledWeekday: null),
      ),
      expect: () => [isA<PreStartLoading>(), isA<PreStartError>()],
    );

    blocTest<PreStartBloc, PreStartState>(
      'PreStartRetried triggers same load as PreStartRequested',
      build: () => _makeBloc(Right(_planWithExercises())),
      act: (bloc) =>
          bloc.add(const PreStartRetried(planId: 'p1', scheduledWeekday: null)),
      expect: () => [isA<PreStartLoading>(), isA<PreStartLoaded>()],
    );

    test(
      'concurrent PreStartRequested while Loading is a no-op (guard fires)',
      () async {
        final repo = _HangingRepo();
        final bloc = PreStartBloc(
          getWorkoutPlanById: GetWorkoutPlanByIdUseCase(repo),
          hasCompletedWorkoutToday: _completedToday(),
        );
        bloc.add(const PreStartRequested(planId: 'p1', scheduledWeekday: null));
        await Future<void>.delayed(Duration.zero);
        expect(bloc.state, isA<PreStartLoading>());
        bloc.add(const PreStartRequested(planId: 'p1', scheduledWeekday: null));
        await Future<void>.delayed(Duration.zero);
        expect(bloc.state, isA<PreStartLoading>());
        await bloc.close();
      },
    );
  });
}
