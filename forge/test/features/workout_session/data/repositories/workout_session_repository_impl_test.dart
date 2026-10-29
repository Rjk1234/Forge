import 'package:flutter_test/flutter_test.dart';
import 'package:forge/core/enums/exercise_type.dart';
import 'package:forge/core/exceptions/app_exception.dart';
import 'package:forge/features/workout_session/data/datasources/workout_session_local_data_source.dart';
import 'package:forge/features/workout_session/data/models/actual_set_record.dart';
import 'package:forge/features/workout_session/data/models/session_exercise_record.dart';
import 'package:forge/features/workout_session/data/models/workout_session_record.dart';
import 'package:forge/features/workout_session/data/repositories/workout_session_repository_impl.dart';
import 'package:forge/features/workout_session/domain/entities/actual_set.dart';
import 'package:forge/features/workout_session/domain/entities/session_exercise.dart';
import 'package:forge/features/workout_session/domain/entities/workout_session.dart';

// ---------------------------------------------------------------------------
// Fake data source
// ---------------------------------------------------------------------------

class _FakeDataSource implements WorkoutSessionLocalDataSource {
  _FakeDataSource({
    this.sessions = const [],
    this.shouldThrow = false,
    this.throwOn = '',
  });

  final List<WorkoutSessionRecord> sessions;
  final bool shouldThrow;
  final String throwOn;

  WorkoutSessionRecord? lastSaved;
  String? lastDeleted;

  @override
  Future<List<WorkoutSessionRecord>> getAllSessions() async {
    if (shouldThrow && (throwOn.isEmpty || throwOn == 'getAll')) {
      throw Exception('database error');
    }
    return sessions;
  }

  @override
  Future<List<WorkoutSessionRecord>> getSessionsByPlanId(String planId) async {
    if (shouldThrow && (throwOn.isEmpty || throwOn == 'getByPlan')) {
      throw Exception('database error');
    }
    return sessions.where((s) => s.planId == planId).toList();
  }

  @override
  Future<WorkoutSessionRecord?> getSessionById(String sessionId) async {
    if (shouldThrow && (throwOn.isEmpty || throwOn == 'getById')) {
      throw Exception('database error');
    }
    try {
      return sessions.firstWhere((s) => s.sessionId == sessionId);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> saveSession(WorkoutSessionRecord model) async {
    if (shouldThrow && (throwOn.isEmpty || throwOn == 'save')) {
      throw Exception('IO error');
    }
    lastSaved = model;
  }

  @override
  Future<void> deleteSession(String sessionId) async {
    if (shouldThrow && (throwOn.isEmpty || throwOn == 'delete')) {
      throw Exception('IO error');
    }
    lastDeleted = sessionId;
  }
}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

WorkoutSessionRecord _sessionRecord({
  String id = 's1',
  String planId = 'p1',
  List<SessionExerciseRecord> exercises = const [],
}) => WorkoutSessionRecord(
  sessionId: id,
  planId: planId,
  planName: 'Plan A',
  completedAt: DateTime(2026, 1, 1),
  sessionDurationSec: 60,
  sessionExercises: exercises,
);

SessionExerciseRecord _exerciseRecord({
  List<ActualSetRecord> sets = const [],
}) => SessionExerciseRecord(
  exerciseId: 'e1',
  exerciseName: 'Squat',
  type: ExerciseType.weighted,
  actualSets: sets,
);

ActualSetRecord _setRecord() => ActualSetRecord(repetitions: 10, weight: 60.0);

WorkoutSession _domainSession({List<SessionExercise> exercises = const []}) =>
    WorkoutSession(
      sessionId: 's1',
      planId: 'p1',
      planName: 'Plan A',
      completedAt: DateTime(2026, 1, 1),
      startedAt: DateTime(2026, 1, 1),
      sessionDurationSec: 60,
      sessionExercises: exercises,
    );

SessionExercise _domainExercise({List<ActualSet> sets = const []}) =>
    SessionExercise(
      exerciseId: 'e1',
      exerciseName: 'Squat',
      type: ExerciseType.weighted,
      actualSets: sets,
    );

const _domainSet = ActualSet(repetitions: 10, weight: 60.0);

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  group('WorkoutSessionRepositoryImpl — getAllSessions', () {
    test('returns mapped domain sessions on success', () async {
      final dataSource = _FakeDataSource(
        sessions: [
          _sessionRecord(
            exercises: [
              _exerciseRecord(sets: [_setRecord()]),
            ],
          ),
        ],
      );
      final repo = WorkoutSessionRepositoryImpl(dataSource: dataSource);

      final result = await repo.getAllSessions();

      expect(result.isRight(), isTrue);
      final sessions = result.getOrElse((_) => []);
      expect(sessions.length, 1);
      expect(sessions.first.sessionId, 's1');
      expect(
        sessions.first.sessionExercises.first.actualSets.first.repetitions,
        10,
      );
    });

    test('returns CacheException when data source throws', () async {
      final dataSource = _FakeDataSource(shouldThrow: true, throwOn: 'getAll');
      final repo = WorkoutSessionRepositoryImpl(dataSource: dataSource);

      final result = await repo.getAllSessions();

      expect(result.isLeft(), isTrue);
      expect(
        result.swap().getOrElse((_) => throw Error()),
        isA<CacheException>(),
      );
    });

    test('returns empty list when no sessions exist', () async {
      final dataSource = _FakeDataSource();
      final repo = WorkoutSessionRepositoryImpl(dataSource: dataSource);

      final result = await repo.getAllSessions();

      expect(result.isRight(), isTrue);
      expect(result.getOrElse((_) => []), isEmpty);
    });
  });

  group('WorkoutSessionRepositoryImpl — getSessionsByPlanId', () {
    test('returns only sessions matching planId', () async {
      final dataSource = _FakeDataSource(
        sessions: [
          _sessionRecord(id: 's1', planId: 'p1'),
          _sessionRecord(id: 's2', planId: 'p2'),
          _sessionRecord(id: 's3', planId: 'p1'),
        ],
      );
      final repo = WorkoutSessionRepositoryImpl(dataSource: dataSource);

      final result = await repo.getSessionsByPlanId('p1');

      expect(result.isRight(), isTrue);
      final sessions = result.getOrElse((_) => []);
      expect(sessions.length, 2);
      expect(sessions.every((s) => s.planId == 'p1'), isTrue);
    });

    test('returns CacheException when data source throws', () async {
      final dataSource = _FakeDataSource(
        shouldThrow: true,
        throwOn: 'getByPlan',
      );
      final repo = WorkoutSessionRepositoryImpl(dataSource: dataSource);

      final result = await repo.getSessionsByPlanId('p1');

      expect(result.isLeft(), isTrue);
    });
  });

  group('WorkoutSessionRepositoryImpl — getSessionById', () {
    test('returns session when found', () async {
      final dataSource = _FakeDataSource(sessions: [_sessionRecord(id: 's1')]);
      final repo = WorkoutSessionRepositoryImpl(dataSource: dataSource);

      final result = await repo.getSessionById('s1');

      expect(result.isRight(), isTrue);
      expect(result.getOrElse((_) => null)?.sessionId, 's1');
    });

    test('returns null Right when session not found', () async {
      final dataSource = _FakeDataSource();
      final repo = WorkoutSessionRepositoryImpl(dataSource: dataSource);

      final result = await repo.getSessionById('nonexistent');

      expect(result.isRight(), isTrue);
      expect(result.getOrElse((_) => throw Error()), isNull);
    });

    test('returns CacheException when data source throws', () async {
      final dataSource = _FakeDataSource(shouldThrow: true, throwOn: 'getById');
      final repo = WorkoutSessionRepositoryImpl(dataSource: dataSource);

      final result = await repo.getSessionById('s1');

      expect(result.isLeft(), isTrue);
    });
  });

  group(
    'WorkoutSessionRepositoryImpl — saveSession (write failure mapping)',
    () {
      test('saves valid session and returns Right', () async {
        final dataSource = _FakeDataSource();
        final repo = WorkoutSessionRepositoryImpl(dataSource: dataSource);
        final session = _domainSession(
          exercises: [
            _domainExercise(sets: [_domainSet]),
          ],
        );

        final result = await repo.saveSession(session);

        expect(result.isRight(), isTrue);
        expect(dataSource.lastSaved?.sessionId, 's1');
      });

      test(
        'returns CacheException when data source throws during save',
        () async {
          final dataSource = _FakeDataSource(
            shouldThrow: true,
            throwOn: 'save',
          );
          final repo = WorkoutSessionRepositoryImpl(dataSource: dataSource);
          final session = _domainSession(
            exercises: [
              _domainExercise(sets: [_domainSet]),
            ],
          );

          final result = await repo.saveSession(session);

          expect(result.isLeft(), isTrue);
          expect(
            result.swap().getOrElse((_) => throw Error()),
            isA<CacheException>(),
          );
        },
      );
    },
  );

  group('WorkoutSessionRepositoryImpl — deleteSession', () {
    test('deletes session and returns Right', () async {
      final dataSource = _FakeDataSource();
      final repo = WorkoutSessionRepositoryImpl(dataSource: dataSource);

      final result = await repo.deleteSession('s1');

      expect(result.isRight(), isTrue);
      expect(dataSource.lastDeleted, 's1');
    });

    test('returns CacheException when data source throws', () async {
      final dataSource = _FakeDataSource(shouldThrow: true, throwOn: 'delete');
      final repo = WorkoutSessionRepositoryImpl(dataSource: dataSource);

      final result = await repo.deleteSession('s1');

      expect(result.isLeft(), isTrue);
    });
  });

  group('WorkoutSessionRepositoryImpl — SC-008 (no hard limit)', () {
    test('returns all 50 sessions without truncation', () async {
      final sessions = List.generate(
        50,
        (i) => _sessionRecord(id: 's$i', planId: 'p1'),
      );
      final dataSource = _FakeDataSource(sessions: sessions);
      final repo = WorkoutSessionRepositoryImpl(dataSource: dataSource);

      final result = await repo.getAllSessions();

      expect(result.isRight(), isTrue);
      expect(result.getOrElse((_) => []).length, 50);
    });
  });

  group('WorkoutSessionRepositoryImpl — SC-009/SC-010 (performance)', () {
    test('saveSession completes in under 1000ms', () async {
      final dataSource = _FakeDataSource();
      final repo = WorkoutSessionRepositoryImpl(dataSource: dataSource);
      final session = _domainSession(
        exercises: List.generate(
          10,
          (_) => _domainExercise(sets: List.generate(3, (_) => _domainSet)),
        ),
      );

      final stopwatch = Stopwatch()..start();
      await repo.saveSession(session);
      stopwatch.stop();

      expect(stopwatch.elapsedMilliseconds, lessThan(1000));
    });

    test('getAllSessions over 50 records completes in under 2000ms', () async {
      final sessions = List.generate(
        50,
        (i) => _sessionRecord(
          id: 's$i',
          exercises: List.generate(
            10,
            (_) => _exerciseRecord(sets: [_setRecord()]),
          ),
        ),
      );
      final dataSource = _FakeDataSource(sessions: sessions);
      final repo = WorkoutSessionRepositoryImpl(dataSource: dataSource);

      final stopwatch = Stopwatch()..start();
      await repo.getAllSessions();
      stopwatch.stop();

      expect(stopwatch.elapsedMilliseconds, lessThan(2000));
    });
  });
}
