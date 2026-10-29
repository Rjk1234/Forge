import 'package:flutter_test/flutter_test.dart';
import 'package:forge/core/enums/exercise_type.dart';
import 'package:forge/features/workout_session/domain/entities/actual_set.dart';
import 'package:forge/features/workout_session/domain/entities/session_exercise.dart';
import 'package:forge/features/workout_session/domain/entities/workout_session.dart';
import 'package:forge/features/workout_session/domain/rules/exercise_history.dart';
import 'package:forge/features/workout_session/domain/rules/session_ordering.dart';

SessionExercise _bench(String name, List<ActualSet> sets) => SessionExercise(
  exerciseId: 'bench',
  exerciseName: name,
  type: ExerciseType.weighted,
  actualSets: sets,
);

WorkoutSession _session(
  String id,
  List<SessionExercise> exercises, {
  DateTime? startedAt,
  DateTime? completedAt,
}) => WorkoutSession(
  sessionId: id,
  planId: 'p',
  planName: 'Plan',
  completedAt: completedAt ?? DateTime(2026, 9, 1, 10),
  startedAt: startedAt ?? DateTime(2026, 9, 1, 9),
  sessionDurationSec: 60,
  sessionExercises: exercises,
);

void main() {
  const set60 = ActualSet(repetitions: 5, weight: 60);
  const set70 = ActualSet(repetitions: 5, weight: 70);

  test(
    'a repeated exercise becomes one entry with concatenated valid sets',
    () {
      final session = _session('s', [
        _bench('Bench', [set60, const ActualSet(skipped: true)]),
        _bench('Bench', [set70]),
      ]);

      final merged = aggregateSessionExercises(session);

      expect(merged, hasLength(1));
      expect(merged.single.actualSets, [set60, set70]);
    },
  );

  test('exercises without a valid set are dropped', () {
    final session = _session('s', [
      _bench('Bench', [const ActualSet(repetitions: 5)]),
    ]);

    expect(aggregateSessionExercises(session), isEmpty);
  });

  test('history has one entry per session, oldest first', () {
    final newer = _session('new', [
      _bench('Bench', [set70]),
      _bench('Bench', [set60]),
    ], startedAt: DateTime(2026, 9, 5));
    final older = _session('old', [
      _bench('Bench', [set60]),
    ], startedAt: DateTime(2026, 9, 1));

    final entries = exerciseHistoryById([newer, older])['bench']!;

    expect(entries.map((entry) => entry.session.sessionId), ['old', 'new']);
  });

  test('a renamed exercise keeps one history under its exerciseId', () {
    final before = _session('a', [
      _bench('Bench', [set60]),
    ]);
    final after = _session('b', [
      _bench('Bench Press', [set70]),
    ], startedAt: DateTime(2026, 9, 2));

    final history = exerciseHistoryById([after, before]);

    expect(history.keys, ['bench']);
    expect(history['bench']!.last.exercise.exerciseName, 'Bench Press');
  });

  test('ordering breaks ties by completedAt then sessionId', () {
    final start = DateTime(2026, 9);
    final early = _session('z', const [], startedAt: start);
    final late = _session(
      'a',
      const [],
      startedAt: start,
      completedAt: DateTime(2026, 9, 1, 11),
    );
    final sameA = _session('a', const [], startedAt: start);
    final sameB = _session('b', const [], startedAt: start);

    expect(compareSessionsOldestFirst(early, late), lessThan(0));
    expect(compareSessionsOldestFirst(sameA, sameB), lessThan(0));
    expect(compareSessionsNewestFirst(sameA, sameB), greaterThan(0));
    expect(compareSessionsOldestFirst(sameA, sameA), 0);
  });
}
