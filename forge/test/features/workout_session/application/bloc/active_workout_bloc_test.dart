import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forge/core/enums/exercise_type.dart';
import 'package:forge/features/workout_plan/domain/entities/plan_exercise.dart';
import 'package:forge/features/workout_plan/domain/entities/workout_plan_detail.dart';
import 'package:forge/features/workout_session/application/bloc/active_workout_bloc.dart';
import 'package:forge/features/workout_session/application/bloc/active_workout_event.dart';
import 'package:forge/features/workout_session/application/bloc/active_workout_state.dart';
import 'package:forge/features/workout_session/domain/validation/session_validator.dart';

// ---------------------------------------------------------------------------
// Mocks
// ---------------------------------------------------------------------------

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

WorkoutPlanDetail _makePlan({
  List<ExerciseType> exerciseTypes = const [ExerciseType.weighted],
}) {
  return WorkoutPlanDetail(
    id: 'p1',
    name: 'Test Plan',
    createdAt: DateTime(2024, 1, 1),
    exercises: exerciseTypes.indexed.map((entry) {
      final (i, type) = entry;
      return PlanExercise(
        exerciseId: 'ex-$i',
        exerciseName: 'Exercise $i',
        type: type,
        targetSets: 1,
        restPeriodSec: 60,
        targetRepetitions: type != ExerciseType.timeBased ? 10 : null,
        targetWeight: type == ExerciseType.weighted ? 50.0 : null,
        targetDurationSec: type == ExerciseType.timeBased ? 30 : null,
      );
    }).toList(),
  );
}

WorkoutPlanDetail _makeSetsPlan({required int restPeriodSec, int sets = 2}) {
  return WorkoutPlanDetail(
    id: 'p1',
    name: 'Test Plan',
    createdAt: DateTime(2024, 1, 1),
    exercises: [
      PlanExercise(
        exerciseId: 'ex-0',
        exerciseName: 'Exercise 0',
        type: ExerciseType.bodyweight,
        targetSets: sets,
        restPeriodSec: restPeriodSec,
        targetRepetitions: 10,
      ),
    ],
  );
}

ActiveWorkoutBloc _makeBloc() => ActiveWorkoutBloc();

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  group('ActiveWorkoutBloc', () {
    // (1) Started → emits Running at ex:0 set:0 all-pending
    blocTest<ActiveWorkoutBloc, ActiveWorkoutState>(
      'Started emits Running at exerciseIndex 0, setIndex 0, all pending',
      build: () => _makeBloc(),
      act: (bloc) => bloc.add(ActiveWorkoutStarted(plan: _makePlan())),
      expect: () => [
        isA<ActiveWorkoutRunning>()
            .having((s) => s.exerciseIndex, 'exerciseIndex', 0)
            .having((s) => s.currentSetIndex, 'currentSetIndex', 0)
            .having((s) => s.setStatuses, 'setStatuses', [SetStatus.pending]),
      ],
    );

    // (2) CompleteSet(reps:10) on weighted → advances to next position / navigates
    blocTest<ActiveWorkoutBloc, ActiveWorkoutState>(
      'CompleteSet with valid reps marks set logged and navigates (single-set plan)',
      build: () => _makeBloc(),
      act: (bloc) {
        bloc
          ..add(ActiveWorkoutStarted(plan: _makePlan()))
          ..add(
            const ActiveWorkoutCompleteSetRequested(reps: 10, weight: 50.0),
          );
      },
      expect: () => [
        isA<ActiveWorkoutRunning>(), // started
        isA<ActiveWorkoutRunning>().having(
          (s) => s.navigateToPostWorkout,
          'navigateToPostWorkout',
          true,
        ),
      ],
    );

    // (3) CompleteSet(reps:0) invalid → repError non-null
    blocTest<ActiveWorkoutBloc, ActiveWorkoutState>(
      'CompleteSet with reps=0 sets repError',
      build: () => _makeBloc(),
      act: (bloc) {
        bloc
          ..add(ActiveWorkoutStarted(plan: _makePlan()))
          ..add(const ActiveWorkoutCompleteSetRequested(reps: 0));
      },
      expect: () => [
        isA<ActiveWorkoutRunning>(), // started
        isA<ActiveWorkoutRunning>().having(
          (s) => s.repError,
          'repError',
          ActiveWorkoutFieldError.repsNotPositive,
        ),
      ],
    );

    // (4) CompleteSet(weight:-1.0) invalid → weightError non-null
    blocTest<ActiveWorkoutBloc, ActiveWorkoutState>(
      'CompleteSet with weight=-1.0 sets weightError',
      build: () => _makeBloc(),
      act: (bloc) {
        bloc
          ..add(ActiveWorkoutStarted(plan: _makePlan()))
          ..add(
            const ActiveWorkoutCompleteSetRequested(reps: 10, weight: -1.0),
          );
      },
      expect: () => [
        isA<ActiveWorkoutRunning>(),
        isA<ActiveWorkoutRunning>().having(
          (s) => s.weightError,
          'weightError',
          ActiveWorkoutFieldError.weightInvalid,
        ),
      ],
    );

    // (5) CompleteSet(durationSec:0) invalid → durationError non-null
    blocTest<ActiveWorkoutBloc, ActiveWorkoutState>(
      'CompleteSet with durationSec=0 on timeBased sets durationError',
      build: () => _makeBloc(),
      act: (bloc) {
        bloc
          ..add(
            ActiveWorkoutStarted(
              plan: _makePlan(exerciseTypes: [ExerciseType.timeBased]),
            ),
          )
          ..add(const ActiveWorkoutCompleteSetRequested(durationSec: 0));
      },
      expect: () => [
        isA<ActiveWorkoutRunning>(),
        isA<ActiveWorkoutRunning>().having(
          (s) => s.durationError,
          'durationError',
          ActiveWorkoutFieldError.durationNotPositive,
        ),
      ],
    );

    // (6) FieldChanged(reps,'5') after repError → repError null
    blocTest<ActiveWorkoutBloc, ActiveWorkoutState>(
      'FieldChanged for reps clears repError',
      build: () => _makeBloc(),
      act: (bloc) {
        bloc
          ..add(ActiveWorkoutStarted(plan: _makePlan()))
          ..add(const ActiveWorkoutCompleteSetRequested(reps: 0))
          ..add(
            const ActiveWorkoutFieldChanged(
              field: ActiveWorkoutField.reps,
              value: '5',
            ),
          );
      },
      expect: () => [
        isA<ActiveWorkoutRunning>(), // started
        isA<ActiveWorkoutRunning>().having(
          (s) => s.repError,
          'repError',
          isNotNull,
        ),
        isA<ActiveWorkoutRunning>().having(
          (s) => s.repError,
          'repError',
          isNull,
        ),
      ],
    );

    // (7) Skip → dot[0]=skipped, navigateToCancel (single-set, 0 logged)
    blocTest<ActiveWorkoutBloc, ActiveWorkoutState>(
      'SkipSet on last-of-last with 0 logged sets navigateToCancel',
      build: () => _makeBloc(),
      act: (bloc) {
        bloc
          ..add(ActiveWorkoutStarted(plan: _makePlan()))
          ..add(const ActiveWorkoutSkipSetRequested());
      },
      expect: () => [
        isA<ActiveWorkoutRunning>(),
        isA<ActiveWorkoutRunning>().having(
          (s) => s.navigateToCancel,
          'navigateToCancel',
          true,
        ),
      ],
    );

    // Skipping the final set after logging earlier sets must finish the workout.
    blocTest<ActiveWorkoutBloc, ActiveWorkoutState>(
      'SkipSet on the last set with a logged set finishes with that set skipped',
      build: () => _makeBloc(),
      act: (bloc) {
        bloc
          ..add(ActiveWorkoutStarted(plan: _makeSetsPlan(restPeriodSec: 0)))
          ..add(const ActiveWorkoutCompleteSetRequested(reps: 8))
          ..add(const ActiveWorkoutSkipSetRequested());
      },
      expect: () => [
        isA<ActiveWorkoutRunning>(),
        isA<ActiveWorkoutRunning>(),
        isA<ActiveWorkoutRunning>()
            .having(
              (s) => s.navigateToPostWorkout,
              'navigateToPostWorkout',
              true,
            )
            .having(
              (s) => s.completedSession?.sessionExercises.single.actualSets
                  .map((set) => set.skipped)
                  .toList(),
              'skipped flags',
              [false, true],
            ),
      ],
    );

    for (final (label, weight) in <(String, double?)>[
      ('a missing weight', null),
      ('a zero weight', 0),
      ('a weight above the limit', 1000.5),
      ('an infinite weight', double.infinity),
      ('a NaN weight', double.nan),
    ]) {
      blocTest<ActiveWorkoutBloc, ActiveWorkoutState>(
        'CompleteSet with $label on a weighted exercise is rejected',
        build: () => _makeBloc(),
        act: (bloc) {
          bloc
            ..add(ActiveWorkoutStarted(plan: _makePlan()))
            ..add(ActiveWorkoutCompleteSetRequested(reps: 8, weight: weight));
        },
        expect: () => [
          isA<ActiveWorkoutRunning>(),
          isA<ActiveWorkoutRunning>()
              .having(
                (s) => s.weightError,
                'weightError',
                ActiveWorkoutFieldError.weightInvalid,
              )
              .having(
                (s) => s.navigateToPostWorkout,
                'navigateToPostWorkout',
                false,
              ),
        ],
      );
    }

    blocTest<ActiveWorkoutBloc, ActiveWorkoutState>(
      'CompleteSet with reps above the limit is rejected',
      build: () => _makeBloc(),
      act: (bloc) {
        bloc
          ..add(ActiveWorkoutStarted(plan: _makePlan()))
          ..add(
            const ActiveWorkoutCompleteSetRequested(reps: 1001, weight: 50),
          );
      },
      expect: () => [
        isA<ActiveWorkoutRunning>(),
        isA<ActiveWorkoutRunning>().having(
          (s) => s.repError,
          'repError',
          ActiveWorkoutFieldError.repsNotPositive,
        ),
      ],
    );

    blocTest<ActiveWorkoutBloc, ActiveWorkoutState>(
      'CompleteSet with a time-based duration above the limit is rejected',
      build: () => _makeBloc(),
      act: (bloc) {
        bloc
          ..add(
            ActiveWorkoutStarted(
              plan: _makePlan(exerciseTypes: [ExerciseType.timeBased]),
            ),
          )
          ..add(const ActiveWorkoutCompleteSetRequested(durationSec: 86401));
      },
      expect: () => [
        isA<ActiveWorkoutRunning>(),
        isA<ActiveWorkoutRunning>().having(
          (s) => s.durationError,
          'durationError',
          ActiveWorkoutFieldError.durationNotPositive,
        ),
      ],
    );

    blocTest<ActiveWorkoutBloc, ActiveWorkoutState>(
      'a finished session always passes the session validator',
      build: () => _makeBloc(),
      act: (bloc) {
        bloc
          ..add(ActiveWorkoutStarted(plan: _makePlan()))
          ..add(const ActiveWorkoutPauseRequested())
          ..add(const ActiveWorkoutResumeRequested())
          ..add(const ActiveWorkoutCompleteSetRequested(reps: 8, weight: 50));
      },
      verify: (bloc) {
        final session = (bloc.state as ActiveWorkoutRunning).completedSession!;
        expect(const SessionValidator().validate(session), isEmpty);
        expect(session.sessionDurationSec, greaterThanOrEqualTo(0));
        expect(session.completedAt.isBefore(session.startedAt), isFalse);
      },
    );

    // (8) Pause → isPaused:true
    blocTest<ActiveWorkoutBloc, ActiveWorkoutState>(
      'PauseRequested sets isPaused to true',
      build: () => _makeBloc(),
      act: (bloc) {
        bloc
          ..add(ActiveWorkoutStarted(plan: _makePlan()))
          ..add(const ActiveWorkoutPauseRequested());
      },
      expect: () => [
        isA<ActiveWorkoutRunning>().having(
          (s) => s.isPaused,
          'isPaused',
          false,
        ),
        isA<ActiveWorkoutRunning>().having((s) => s.isPaused, 'isPaused', true),
      ],
    );

    // (9) Resume → isPaused:false
    blocTest<ActiveWorkoutBloc, ActiveWorkoutState>(
      'ResumeRequested clears isPaused',
      build: () => _makeBloc(),
      act: (bloc) {
        bloc
          ..add(ActiveWorkoutStarted(plan: _makePlan()))
          ..add(const ActiveWorkoutPauseRequested())
          ..add(const ActiveWorkoutResumeRequested());
      },
      expect: () => [
        isA<ActiveWorkoutRunning>().having(
          (s) => s.isPaused,
          'isPaused',
          false,
        ),
        isA<ActiveWorkoutRunning>().having((s) => s.isPaused, 'isPaused', true),
        isA<ActiveWorkoutRunning>().having(
          (s) => s.isPaused,
          'isPaused',
          false,
        ),
      ],
    );

    // (10) Complete last set, ≥1 logged, use case Right → navigateToPostWorkout
    blocTest<ActiveWorkoutBloc, ActiveWorkoutState>(
      'Finishing with ≥1 logged set navigates to post-workout on success',
      build: () => _makeBloc(),
      act: (bloc) {
        bloc
          ..add(ActiveWorkoutStarted(plan: _makePlan()))
          ..add(const ActiveWorkoutCompleteSetRequested(reps: 8, weight: 50.0));
      },
      expect: () => [
        isA<ActiveWorkoutRunning>(),
        isA<ActiveWorkoutRunning>().having(
          (s) => s.navigateToPostWorkout,
          'navigateToPostWorkout',
          true,
        ),
      ],
    );

    // (11) Complete last set, 0 logged → navigateToCancel
    blocTest<ActiveWorkoutBloc, ActiveWorkoutState>(
      'Finishing last set with 0 logged sets navigateToCancel',
      build: () => _makeBloc(),
      act: (bloc) {
        // Two-exercise plan: skip both sets, then complete second exercise's set
        // (logged count still 0 since first was skipped).
        // Simpler: single-exercise plan, complete with 0 logged is impossible;
        // use skip then complete: but completing logs it.
        // Easiest: single-exercise, skip the set (last-of-last, 0 logged).
        bloc
          ..add(ActiveWorkoutStarted(plan: _makePlan()))
          ..add(const ActiveWorkoutSkipSetRequested());
      },
      expect: () => [
        isA<ActiveWorkoutRunning>(),
        isA<ActiveWorkoutRunning>().having(
          (s) => s.navigateToCancel,
          'navigateToCancel',
          true,
        ),
      ],
    );

    // (12) Finish builds the session and hands it over via state
    blocTest<ActiveWorkoutBloc, ActiveWorkoutState>(
      'Finish emits the completed session for the summary screen',
      build: () => _makeBloc(),
      act: (bloc) {
        bloc
          ..add(ActiveWorkoutStarted(plan: _makePlan()))
          ..add(const ActiveWorkoutCompleteSetRequested(reps: 8, weight: 50.0));
      },
      skip: 1,
      expect: () => [
        isA<ActiveWorkoutRunning>()
            .having(
              (s) => s.navigateToPostWorkout,
              'navigateToPostWorkout',
              true,
            )
            .having(
              (s) => s.completedSession?.planName,
              'completedSession.planName',
              'Test Plan',
            )
            .having(
              (s) => s
                  .completedSession
                  ?.sessionExercises
                  .single
                  .actualSets
                  .single
                  .repetitions,
              'logged reps',
              8,
            ),
      ],
    );

    // (13) PostWorkoutNavigated resets the hand-over flags
    blocTest<ActiveWorkoutBloc, ActiveWorkoutState>(
      'PostWorkoutNavigated clears navigateToPostWorkout and completedSession',
      build: () => _makeBloc(),
      act: (bloc) {
        bloc
          ..add(ActiveWorkoutStarted(plan: _makePlan()))
          ..add(const ActiveWorkoutCompleteSetRequested(reps: 8, weight: 50.0))
          ..add(const ActiveWorkoutPostWorkoutNavigated());
      },
      skip: 2,
      expect: () => [
        isA<ActiveWorkoutRunning>()
            .having(
              (s) => s.navigateToPostWorkout,
              'navigateToPostWorkout',
              false,
            )
            .having((s) => s.completedSession, 'completedSession', isNull),
      ],
    );

    // SCR-17: rest timer navigation flags
    blocTest<ActiveWorkoutBloc, ActiveWorkoutState>(
      'CompleteSet with restPeriodSec > 0 advances and flags rest timer',
      build: () => _makeBloc(),
      act: (bloc) {
        bloc
          ..add(ActiveWorkoutStarted(plan: _makeSetsPlan(restPeriodSec: 45)))
          ..add(const ActiveWorkoutCompleteSetRequested(reps: 10));
      },
      expect: () => [
        isA<ActiveWorkoutRunning>(),
        isA<ActiveWorkoutRunning>()
            .having((s) => s.currentSetIndex, 'currentSetIndex', 1)
            .having((s) => s.navigateToRestTimer, 'navigateToRestTimer', true)
            .having((s) => s.restPeriodSec, 'restPeriodSec', 45),
      ],
    );

    blocTest<ActiveWorkoutBloc, ActiveWorkoutState>(
      'RestTimerNavigated resets the rest timer flags',
      build: () => _makeBloc(),
      act: (bloc) {
        bloc
          ..add(ActiveWorkoutStarted(plan: _makeSetsPlan(restPeriodSec: 45)))
          ..add(const ActiveWorkoutCompleteSetRequested(reps: 10))
          ..add(const ActiveWorkoutRestTimerNavigated());
      },
      skip: 2,
      expect: () => [
        isA<ActiveWorkoutRunning>()
            .having((s) => s.currentSetIndex, 'currentSetIndex', 1)
            .having((s) => s.navigateToRestTimer, 'navigateToRestTimer', false)
            .having((s) => s.restPeriodSec, 'restPeriodSec', 0),
      ],
    );

    blocTest<ActiveWorkoutBloc, ActiveWorkoutState>(
      'CompleteSet with restPeriodSec = 0 bypasses the rest timer (FR-006)',
      build: () => _makeBloc(),
      act: (bloc) {
        bloc
          ..add(ActiveWorkoutStarted(plan: _makeSetsPlan(restPeriodSec: 0)))
          ..add(const ActiveWorkoutCompleteSetRequested(reps: 10));
      },
      skip: 1,
      expect: () => [
        isA<ActiveWorkoutRunning>()
            .having((s) => s.currentSetIndex, 'currentSetIndex', 1)
            .having((s) => s.navigateToRestTimer, 'navigateToRestTimer', false),
      ],
    );

    blocTest<ActiveWorkoutBloc, ActiveWorkoutState>(
      'CompleteSet on last set with restPeriodSec > 0 finishes without rest (FR-008)',
      build: () => _makeBloc(),
      act: (bloc) {
        bloc
          ..add(
            ActiveWorkoutStarted(
              plan: _makeSetsPlan(restPeriodSec: 45, sets: 1),
            ),
          )
          ..add(const ActiveWorkoutCompleteSetRequested(reps: 10));
      },
      skip: 1,
      expect: () => [
        isA<ActiveWorkoutRunning>()
            .having(
              (s) => s.navigateToPostWorkout,
              'navigateToPostWorkout',
              true,
            )
            .having((s) => s.navigateToRestTimer, 'navigateToRestTimer', false),
      ],
    );

    // SCR-18: cancel flow
    blocTest<ActiveWorkoutBloc, ActiveWorkoutState>(
      'Started exposes the plan name',
      build: () => _makeBloc(),
      act: (bloc) => bloc.add(ActiveWorkoutStarted(plan: _makePlan())),
      expect: () => [
        isA<ActiveWorkoutRunning>().having(
          (s) => s.planName,
          'planName',
          'Test Plan',
        ),
      ],
    );

    blocTest<ActiveWorkoutBloc, ActiveWorkoutState>(
      'CancelRequested sets navigateToCancel',
      build: () => _makeBloc(),
      act: (bloc) {
        bloc
          ..add(ActiveWorkoutStarted(plan: _makePlan()))
          ..add(const ActiveWorkoutCancelRequested());
      },
      skip: 1,
      expect: () => [
        isA<ActiveWorkoutRunning>().having(
          (s) => s.navigateToCancel,
          'navigateToCancel',
          true,
        ),
      ],
    );

    blocTest<ActiveWorkoutBloc, ActiveWorkoutState>(
      'CancelNavigated resets navigateToCancel',
      build: () => _makeBloc(),
      act: (bloc) {
        bloc
          ..add(ActiveWorkoutStarted(plan: _makePlan()))
          ..add(const ActiveWorkoutCancelRequested())
          ..add(const ActiveWorkoutCancelNavigated());
      },
      skip: 2,
      expect: () => [
        isA<ActiveWorkoutRunning>().having(
          (s) => s.navigateToCancel,
          'navigateToCancel',
          false,
        ),
      ],
    );

    blocTest<ActiveWorkoutBloc, ActiveWorkoutState>(
      'CancelRequested before start leaves state unchanged',
      build: () => _makeBloc(),
      act: (bloc) => bloc.add(const ActiveWorkoutCancelRequested()),
      expect: () => <ActiveWorkoutState>[],
    );

    blocTest<ActiveWorkoutBloc, ActiveWorkoutState>(
      'a second cancel after Keep Going raises the flag again',
      build: () => _makeBloc(),
      act: (bloc) {
        bloc
          ..add(ActiveWorkoutStarted(plan: _makePlan()))
          ..add(const ActiveWorkoutCancelRequested())
          ..add(const ActiveWorkoutCancelNavigated())
          ..add(const ActiveWorkoutCancelRequested());
      },
      skip: 3,
      expect: () => [
        isA<ActiveWorkoutRunning>().having(
          (s) => s.navigateToCancel,
          'navigateToCancel',
          true,
        ),
      ],
    );
  });
}
