import 'package:flutter_test/flutter_test.dart';
import 'package:forge/core/enums/exercise_type.dart';
import 'package:forge/core/exceptions/app_exception.dart';
import 'package:forge/features/workout_session/data/datasources/workout_session_local_data_source.dart';
import 'package:forge/features/workout_session/data/models/workout_session_record.dart';
import 'package:forge/features/workout_session/data/repositories/workout_session_repository_impl.dart';
import 'package:forge/features/workout_session/domain/entities/actual_set.dart';
import 'package:forge/features/workout_session/domain/entities/session_exercise.dart';
import 'package:forge/features/workout_session/domain/entities/workout_session.dart';

// ---------------------------------------------------------------------------
// Spy data source — records whether saveSession was called
// ---------------------------------------------------------------------------

class _SpyDataSource implements WorkoutSessionLocalDataSource {
  int saveCallCount = 0;

  @override
  Future<List<WorkoutSessionRecord>> getAllSessions() async => [];

  @override
  Future<List<WorkoutSessionRecord>> getSessionsByPlanId(String planId) async =>
      [];

  @override
  Future<WorkoutSessionRecord?> getSessionById(String sessionId) async => null;

  @override
  Future<void> saveSession(WorkoutSessionRecord model) async {
    saveCallCount++;
  }

  @override
  Future<void> deleteSession(String sessionId) async {}
}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

WorkoutSession _session({required List<SessionExercise> exercises}) =>
    WorkoutSession(
      sessionId: 's1',
      planId: 'p1',
      planName: 'Plan A',
      completedAt: DateTime(2026, 1, 1),
      startedAt: DateTime(2026, 1, 1),
      sessionDurationSec: 60,
      sessionExercises: exercises,
    );

SessionExercise _exercise({required List<ActualSet> sets}) => SessionExercise(
  exerciseId: 'e1',
  exerciseName: 'Squat',
  type: ExerciseType.weighted,
  actualSets: sets,
);

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  group(
    'WorkoutSessionRepositoryImpl — completion criterion (FR-003, FR-004)',
    () {
      test('(a) empty sessionExercises returns Left(CacheException) '
          'and data source is never called', () async {
        final spy = _SpyDataSource();
        final repo = WorkoutSessionRepositoryImpl(dataSource: spy);

        final result = await repo.saveSession(_session(exercises: []));

        expect(
          result.isLeft(),
          isTrue,
          reason:
              'A session with no exercises must fail the completion criterion.',
        );
        result.fold(
          (failure) => expect(failure, isA<CacheException>()),
          (_) => fail('Expected Left'),
        );
        expect(
          spy.saveCallCount,
          0,
          reason:
              'Data source must not be called when the criterion is not met.',
        );
      });

      test(
        '(b) one exercise with empty actualSets returns Left(CacheException) '
        'and data source is never called',
        () async {
          final spy = _SpyDataSource();
          final repo = WorkoutSessionRepositoryImpl(dataSource: spy);

          final session = _session(exercises: [_exercise(sets: [])]);

          final result = await repo.saveSession(session);

          expect(
            result.isLeft(),
            isTrue,
            reason:
                'A session where all exercises have no recorded sets '
                'must fail the completion criterion.',
          );
          result.fold(
            (failure) => expect(failure, isA<CacheException>()),
            (_) => fail('Expected Left'),
          );
          expect(
            spy.saveCallCount,
            0,
            reason:
                'Data source must not be called when the criterion is not met.',
          );
        },
      );

      test(
        '(b-variant) multiple exercises all with empty actualSets '
        'returns Left(CacheException) and data source is never called',
        () async {
          final spy = _SpyDataSource();
          final repo = WorkoutSessionRepositoryImpl(dataSource: spy);

          final session = _session(
            exercises: [
              _exercise(sets: []),
              SessionExercise(
                exerciseId: 'e2',
                exerciseName: 'Bench',
                type: ExerciseType.weighted,
                actualSets: [],
              ),
            ],
          );

          final result = await repo.saveSession(session);

          expect(result.isLeft(), isTrue);
          expect(spy.saveCallCount, 0);
        },
      );

      test('(c) one exercise with one recorded set returns Right(unit) '
          'and data source is called exactly once', () async {
        final spy = _SpyDataSource();
        final repo = WorkoutSessionRepositoryImpl(dataSource: spy);

        final session = _session(
          exercises: [
            _exercise(sets: [const ActualSet(repetitions: 5, weight: 100.0)]),
          ],
        );

        final result = await repo.saveSession(session);

        expect(
          result.isRight(),
          isTrue,
          reason:
              'A session with at least one exercise containing at least one '
              'recorded set must satisfy the completion criterion.',
        );
        expect(
          spy.saveCallCount,
          1,
          reason:
              'Data source must be called exactly once for a valid session.',
        );
      });

      test('(c-variant) mixed exercises — at least one has sets — '
          'returns Right(unit)', () async {
        final spy = _SpyDataSource();
        final repo = WorkoutSessionRepositoryImpl(dataSource: spy);

        // First exercise has no sets; second has one — criterion must pass.
        final session = _session(
          exercises: [
            _exercise(sets: []),
            SessionExercise(
              exerciseId: 'e2',
              exerciseName: 'Bench',
              type: ExerciseType.weighted,
              actualSets: [const ActualSet(repetitions: 8, weight: 80.0)],
            ),
          ],
        );

        final result = await repo.saveSession(session);

        expect(result.isRight(), isTrue);
        expect(spy.saveCallCount, 1);
      });

      test('(e) a session whose sets are all skipped is rejected '
          'and the data source is never called', () async {
        final spy = _SpyDataSource();
        final repo = WorkoutSessionRepositoryImpl(dataSource: spy);

        final result = await repo.saveSession(
          _session(
            exercises: [
              _exercise(sets: const [ActualSet(skipped: true)]),
            ],
          ),
        );

        expect(result.isLeft(), isTrue);
        expect(spy.saveCallCount, 0);
      });

      test('(f) a weighted set logged without a weight is rejected', () async {
        final spy = _SpyDataSource();
        final repo = WorkoutSessionRepositoryImpl(dataSource: spy);

        final result = await repo.saveSession(
          _session(
            exercises: [
              _exercise(sets: const [ActualSet(repetitions: 8)]),
            ],
          ),
        );

        expect(result.isLeft(), isTrue);
        expect(spy.saveCallCount, 0);
      });
    },
  );
}
