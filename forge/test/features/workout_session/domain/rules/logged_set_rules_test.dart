import 'package:flutter_test/flutter_test.dart';
import 'package:forge/core/enums/exercise_type.dart';
import 'package:forge/features/workout_session/domain/entities/actual_set.dart';
import 'package:forge/features/workout_session/domain/entities/session_exercise.dart';
import 'package:forge/features/workout_session/domain/entities/workout_session.dart';
import 'package:forge/features/workout_session/domain/rules/logged_set_rules.dart';

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
  group('isValidLoggedSet weighted', () {
    bool valid(ActualSet set) => isValidLoggedSet(set, ExerciseType.weighted);

    test('needs reps and weight', () {
      expect(valid(const ActualSet(repetitions: 5, weight: 60)), isTrue);
      expect(valid(const ActualSet(repetitions: 5)), isFalse);
      expect(valid(const ActualSet(weight: 60)), isFalse);
    });

    test('rejects zero, negative, NaN and infinite values', () {
      expect(valid(const ActualSet(repetitions: 0, weight: 60)), isFalse);
      expect(valid(const ActualSet(repetitions: 5, weight: 0)), isFalse);
      expect(valid(const ActualSet(repetitions: 5, weight: -1)), isFalse);
      expect(
        valid(const ActualSet(repetitions: 5, weight: double.nan)),
        isFalse,
      );
      expect(
        valid(const ActualSet(repetitions: 5, weight: double.infinity)),
        isFalse,
      );
    });

    test('a skipped set is never valid', () {
      expect(
        valid(const ActualSet(repetitions: 5, weight: 60, skipped: true)),
        isFalse,
      );
    });
  });

  test('bodyweight needs reps only', () {
    bool valid(ActualSet set) => isValidLoggedSet(set, ExerciseType.bodyweight);
    expect(valid(const ActualSet(repetitions: 10)), isTrue);
    expect(valid(const ActualSet()), isFalse);
    expect(valid(const ActualSet(repetitions: 0)), isFalse);
    expect(valid(const ActualSet(durationSec: 30)), isFalse);
  });

  test('time-based needs a positive duration', () {
    bool valid(ActualSet set) => isValidLoggedSet(set, ExerciseType.timeBased);
    expect(valid(const ActualSet(durationSec: 30)), isTrue);
    expect(valid(const ActualSet()), isFalse);
    expect(valid(const ActualSet(durationSec: 0)), isFalse);
    expect(valid(const ActualSet(repetitions: 5)), isFalse);
  });

  test('validLoggedSets keeps only valid sets', () {
    const exercise = SessionExercise(
      exerciseId: 'b',
      exerciseName: 'Bench',
      type: ExerciseType.weighted,
      actualSets: [
        ActualSet(repetitions: 5, weight: 60),
        ActualSet(repetitions: 5),
        ActualSet(skipped: true),
      ],
    );

    expect(validLoggedSets(exercise), [
      const ActualSet(repetitions: 5, weight: 60),
    ]);
  });

  test('a session is completed with one valid set only', () {
    const invalid = SessionExercise(
      exerciseId: 'b',
      exerciseName: 'Bench',
      type: ExerciseType.weighted,
      actualSets: [ActualSet(repetitions: 5)],
    );
    const valid = SessionExercise(
      exerciseId: 'p',
      exerciseName: 'Push-Up',
      type: ExerciseType.bodyweight,
      actualSets: [ActualSet(repetitions: 5)],
    );

    expect(isCompletedSession(_session(const [invalid])), isFalse);
    expect(isCompletedSession(_session(const [invalid, valid])), isTrue);
  });
}
