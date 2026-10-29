import 'package:flutter_test/flutter_test.dart';
import 'package:forge/core/enums/exercise_type.dart';
import 'package:forge/features/workout_session/domain/entities/actual_set.dart';
import 'package:forge/features/workout_session/domain/entities/session_exercise.dart';
import 'package:forge/features/workout_session/domain/entities/workout_session.dart';
import 'package:forge/features/workout_session/domain/validation/session_validator.dart';
import 'package:forge/features/workout_session/domain/validation/session_violation.dart';

final _start = DateTime(2026, 1, 1, 9);

SessionExercise _bench(List<ActualSet> sets) => SessionExercise(
  exerciseId: 'ex_bench',
  exerciseName: 'Bench Press',
  type: ExerciseType.weighted,
  actualSets: sets,
);

WorkoutSession _session({
  String sessionId = 's1',
  String planId = 'p1',
  String planName = 'Push',
  int durationSec = 3600,
  DateTime? completedAt,
  List<SessionExercise>? exercises,
}) => WorkoutSession(
  sessionId: sessionId,
  planId: planId,
  planName: planName,
  completedAt: completedAt ?? _start.add(const Duration(hours: 1)),
  startedAt: _start,
  sessionDurationSec: durationSec,
  sessionExercises:
      exercises ??
      [
        _bench(const [ActualSet(repetitions: 8, weight: 60)]),
      ],
);

List<SessionViolationType> _types(WorkoutSession session) =>
    const SessionValidator().validate(session).map((v) => v.type).toList();

void main() {
  test('a normal session has no violations', () {
    expect(_types(_session()), isEmpty);
  });

  test('missing ids and plan reference are rejected', () {
    expect(_types(_session(sessionId: ' ')), [
      SessionViolationType.missingSessionId,
    ]);
    expect(_types(_session(planId: '')), [
      SessionViolationType.missingPlanReference,
    ]);
  });

  test('a negative or oversized duration is rejected', () {
    expect(_types(_session(durationSec: -1)), [
      SessionViolationType.invalidDuration,
    ]);
    expect(_types(_session(durationSec: 999999)), [
      SessionViolationType.invalidDuration,
    ]);
  });

  test('completion before the start is rejected', () {
    expect(
      _types(
        _session(completedAt: _start.subtract(const Duration(minutes: 1))),
      ),
      [SessionViolationType.invalidTimeRange],
    );
  });

  test('a session without exercises is rejected', () {
    expect(_types(_session(exercises: const [])), [
      SessionViolationType.noExercises,
    ]);
  });

  test('an exercise without sets is rejected', () {
    expect(
      _types(
        _session(
          exercises: [
            _bench(const [ActualSet(repetitions: 8, weight: 60)]),
            _bench(const []),
          ],
        ),
      ),
      [SessionViolationType.exerciseWithoutSets],
    );
  });

  test('a logged weighted set needs reps and a positive finite weight', () {
    for (final bad in const [
      ActualSet(repetitions: 8),
      ActualSet(repetitions: 0, weight: 60),
      ActualSet(repetitions: 8, weight: -1),
      ActualSet(repetitions: 8, weight: double.infinity),
    ]) {
      final types = _types(
        _session(
          exercises: [
            _bench([const ActualSet(repetitions: 8, weight: 60), bad]),
          ],
        ),
      );
      expect(types, contains(SessionViolationType.invalidSet), reason: '$bad');
    }
  });

  test('skipped sets are allowed when they carry no nonsense values', () {
    expect(
      _types(
        _session(
          exercises: [
            _bench(const [
              ActualSet(repetitions: 8, weight: 60),
              ActualSet(skipped: true),
            ]),
          ],
        ),
      ),
      isEmpty,
    );
  });

  test('a session whose sets are all skipped has no valid logged set', () {
    expect(
      _types(
        _session(
          exercises: [
            _bench(const [ActualSet(skipped: true), ActualSet(skipped: true)]),
          ],
        ),
      ),
      [SessionViolationType.noValidLoggedSet],
    );
  });
}
