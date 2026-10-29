import 'package:flutter_test/flutter_test.dart';
import 'package:forge/core/enums/exercise_type.dart';
import 'package:forge/features/workout_session/domain/entities/actual_set.dart';
import 'package:forge/features/workout_session/domain/entities/session_exercise.dart';
import 'package:forge/features/workout_session/domain/entities/workout_session.dart';

void main() {
  final completedAt = DateTime(2026, 3, 1);

  const set1 = ActualSet(repetitions: 10, weight: 60.0);
  const exercise1 = SessionExercise(
    exerciseId: 'e1',
    exerciseName: 'Bench Press',
    type: ExerciseType.weighted,
    actualSets: [set1],
  );
  final session = WorkoutSession(
    sessionId: 'sess-1',
    planId: 'plan-1',
    planName: 'Push Day',
    completedAt: completedAt,
    startedAt: completedAt,
    sessionDurationSec: 1800,
    sessionExercises: [exercise1],
  );

  group('ActualSet — immutable entity contract', () {
    test('all fields match constructor arguments', () {
      const s = ActualSet(repetitions: 8, weight: 80.0, durationSec: null);
      expect(s.repetitions, 8);
      expect(s.weight, 80.0);
      expect(s.durationSec, isNull);
    });

    test('timeBased set has only durationSec', () {
      const s = ActualSet(durationSec: 45);
      expect(s.durationSec, 45);
      expect(s.repetitions, isNull);
      expect(s.weight, isNull);
    });

    test('bodyweight set has only repetitions', () {
      const s = ActualSet(repetitions: 20);
      expect(s.repetitions, 20);
      expect(s.weight, isNull);
      expect(s.durationSec, isNull);
    });
  });

  group('SessionExercise — immutable entity contract', () {
    test('all fields match constructor arguments', () {
      expect(exercise1.exerciseId, 'e1');
      expect(exercise1.exerciseName, 'Bench Press');
      expect(exercise1.type, ExerciseType.weighted);
      expect(exercise1.actualSets, [set1]);
    });
  });

  group('WorkoutSession — immutable entity contract', () {
    test('all fields match constructor arguments', () {
      expect(session.sessionId, 'sess-1');
      expect(session.planId, 'plan-1');
      expect(session.planName, 'Push Day');
      expect(session.completedAt, completedAt);
      expect(session.startedAt, completedAt);
      expect(session.sessionDurationSec, 1800);
      expect(session.sessionExercises, [exercise1]);
    });

    test('Equatable equality — same values are equal', () {
      final session2 = WorkoutSession(
        sessionId: 'sess-1',
        planId: 'plan-1',
        planName: 'Push Day',
        completedAt: completedAt,
        startedAt: completedAt,
        sessionDurationSec: 1800,
        sessionExercises: [exercise1],
      );
      expect(session, equals(session2));
    });

    test('Equatable equality — different sessionId is not equal', () {
      final session2 = WorkoutSession(
        sessionId: 'sess-2',
        planId: 'plan-1',
        planName: 'Push Day',
        completedAt: completedAt,
        startedAt: completedAt,
        sessionDurationSec: 1800,
        sessionExercises: [exercise1],
      );
      expect(session, isNot(equals(session2)));
    });
  });
}
