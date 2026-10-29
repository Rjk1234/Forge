import 'package:flutter_test/flutter_test.dart';
import 'package:forge/core/enums/exercise_type.dart';
import 'package:forge/features/workout_session/domain/entities/actual_set.dart';
import 'package:forge/features/workout_session/domain/entities/session_exercise.dart';
import 'package:forge/features/workout_session/domain/entities/workout_session.dart';
import 'package:forge/features/workout_session/domain/rules/workout_volume.dart';

SessionExercise _exercise(ExerciseType type, List<ActualSet> sets) =>
    SessionExercise(
      exerciseId: type.name,
      exerciseName: type.name,
      type: type,
      actualSets: sets,
    );

WorkoutSession _session(List<SessionExercise> exercises) => WorkoutSession(
  sessionId: 's',
  planId: 'p',
  planName: 'Plan',
  completedAt: DateTime(2026, 9),
  startedAt: DateTime(2026, 9),
  sessionDurationSec: 60,
  sessionExercises: exercises,
);

void main() {
  test('roundToOneDecimal removes floating-point noise', () {
    expect(roundToOneDecimal(0.1 + 0.2), 0.3);
    expect(roundToOneDecimal(72.5 - 70.2), 2.3);
    expect(roundToOneDecimal(1100), 1100);
  });

  test('weighted volume is the sum of weight x reps of valid sets', () {
    final exercise = _exercise(ExerciseType.weighted, const [
      ActualSet(repetitions: 10, weight: 60),
      ActualSet(repetitions: 8, weight: 62.5),
      ActualSet(repetitions: 5),
      ActualSet(repetitions: 9, weight: 100, skipped: true),
    ]);

    expect(exerciseVolume(exercise), 1100);
  });

  test('fractional volume is rounded to one decimal', () {
    final exercise = _exercise(ExerciseType.weighted, const [
      ActualSet(repetitions: 1, weight: 10.4),
      ActualSet(repetitions: 1, weight: 10.4),
    ]);

    expect(exerciseVolume(exercise), 20.8);
  });

  test('bodyweight and time-based exercises carry no volume', () {
    expect(
      exerciseVolume(
        _exercise(ExerciseType.bodyweight, const [ActualSet(repetitions: 20)]),
      ),
      0,
    );
    expect(
      exerciseVolume(
        _exercise(ExerciseType.timeBased, const [ActualSet(durationSec: 60)]),
      ),
      0,
    );
  });

  test('totalVolume sums every session', () {
    final session = _session([
      _exercise(ExerciseType.weighted, const [
        ActualSet(repetitions: 1, weight: 10.4),
      ]),
    ]);

    expect(totalVolume([session, session]), 20.8);
    expect(totalVolume(const []), 0);
  });
}
