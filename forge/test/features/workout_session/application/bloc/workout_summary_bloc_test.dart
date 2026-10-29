import 'package:forge/features/workout_session/domain/usecases/save_workout_session_usecase.dart';
import 'package:forge/features/exercise/domain/entities/exercise.dart';
import '../../../../helpers/fake_exercise_repository.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forge/core/enums/exercise_type.dart';
import 'package:forge/core/exceptions/app_exception.dart';
import 'package:forge/features/workout_session/application/bloc/workout_summary_bloc.dart';
import 'package:forge/features/workout_session/application/bloc/workout_summary_event.dart';
import 'package:forge/features/workout_session/application/bloc/workout_summary_state.dart';
import 'package:forge/features/workout_session/domain/entities/actual_set.dart';
import 'package:forge/features/workout_session/domain/entities/session_exercise.dart';
import 'package:forge/features/workout_session/domain/entities/workout_session.dart';
import 'package:forge/features/workout_session/domain/repositories/workout_session_repository.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';

class _MockRepository extends Mock implements WorkoutSessionRepository {}

const _catalogue = [
  Exercise(id: 'ex-1', name: 'Bench Press', type: ExerciseType.weighted),
];

final _session = WorkoutSession(
  sessionId: 'session-1',
  planId: 'plan-1',
  planName: 'Push Day',
  completedAt: DateTime(2024, 1, 1, 10),
  startedAt: DateTime(2024, 1, 1, 9),
  sessionDurationSec: 3600,
  sessionExercises: const [
    SessionExercise(
      exerciseId: 'ex-1',
      exerciseName: 'Bench Press',
      type: ExerciseType.weighted,
      actualSets: [ActualSet(repetitions: 8, weight: 60)],
    ),
  ],
);

Matcher _loading() => isA<WorkoutSummaryLoading>().having(
  (s) => s.planName,
  'planName',
  'Push Day',
);

Matcher _success() => isA<WorkoutSummarySuccess>().having(
  (s) => s.session.sessionId,
  'sessionId',
  'session-1',
);

Matcher _error() => isA<WorkoutSummaryError>()
    .having((s) => s.planName, 'planName', 'Push Day')
    .having((s) => s.sessionId, 'sessionId', 'session-1');

void main() {
  late _MockRepository repository;

  setUpAll(() {
    registerFallbackValue(_session);
  });

  setUp(() {
    repository = _MockRepository();
  });

  void stubNotYetSaved() {
    when(
      () => repository.getSessionById(any()),
    ).thenAnswer((_) async => const Right(null));
  }

  void stubSaveOk() {
    when(
      () => repository.saveSession(any()),
    ).thenAnswer((_) async => const Right(null));
  }

  void stubSaveFails() {
    when(
      () => repository.saveSession(any()),
    ).thenAnswer((_) async => Left(CacheException(message: 'disk full')));
  }

  group('WorkoutSummaryBloc — first save', () {
    blocTest<WorkoutSummaryBloc, WorkoutSummaryState>(
      'emits Loading then Success when the save succeeds',
      setUp: () {
        stubNotYetSaved();
        stubSaveOk();
      },
      build: () => WorkoutSummaryBloc(
        repository: repository,
        saveSession: SaveWorkoutSessionUseCase(
          repository: repository,
          exerciseRepository: const FakeExerciseRepository(_catalogue),
        ),
      ),
      act: (bloc) => bloc.add(WorkoutSummaryStarted(session: _session)),
      expect: () => [_loading(), _success()],
      verify: (_) => verify(() => repository.saveSession(_session)).called(1),
    );

    blocTest<WorkoutSummaryBloc, WorkoutSummaryState>(
      'skips the write when the session is already stored',
      setUp: () {
        when(
          () => repository.getSessionById('session-1'),
        ).thenAnswer((_) async => Right(_session));
      },
      build: () => WorkoutSummaryBloc(
        repository: repository,
        saveSession: SaveWorkoutSessionUseCase(
          repository: repository,
          exerciseRepository: const FakeExerciseRepository(_catalogue),
        ),
      ),
      act: (bloc) => bloc.add(WorkoutSummaryStarted(session: _session)),
      expect: () => [_loading(), _success()],
      verify: (_) => verifyNever(() => repository.saveSession(any())),
    );

    blocTest<WorkoutSummaryBloc, WorkoutSummaryState>(
      'emits Loading then Error when the save fails',
      setUp: () {
        stubNotYetSaved();
        stubSaveFails();
      },
      build: () => WorkoutSummaryBloc(
        repository: repository,
        saveSession: SaveWorkoutSessionUseCase(
          repository: repository,
          exerciseRepository: const FakeExerciseRepository(_catalogue),
        ),
      ),
      act: (bloc) => bloc.add(WorkoutSummaryStarted(session: _session)),
      expect: () => [_loading(), _error()],
    );

    blocTest<WorkoutSummaryBloc, WorkoutSummaryState>(
      'still attempts the save when the duplicate lookup fails',
      setUp: () {
        when(
          () => repository.getSessionById(any()),
        ).thenAnswer((_) async => Left(CacheException(message: 'read failed')));
        stubSaveOk();
      },
      build: () => WorkoutSummaryBloc(
        repository: repository,
        saveSession: SaveWorkoutSessionUseCase(
          repository: repository,
          exerciseRepository: const FakeExerciseRepository(_catalogue),
        ),
      ),
      act: (bloc) => bloc.add(WorkoutSummaryStarted(session: _session)),
      expect: () => [_loading(), _success()],
    );
  });

  group('WorkoutSummaryBloc — retry', () {
    blocTest<WorkoutSummaryBloc, WorkoutSummaryState>(
      'retry after a failure succeeds and keeps the same session',
      setUp: () {
        stubNotYetSaved();
        var attempts = 0;
        when(() => repository.saveSession(any())).thenAnswer((_) async {
          attempts++;
          return attempts == 1
              ? Left(CacheException(message: 'disk full'))
              : const Right(null);
        });
      },
      build: () => WorkoutSummaryBloc(
        repository: repository,
        saveSession: SaveWorkoutSessionUseCase(
          repository: repository,
          exerciseRepository: const FakeExerciseRepository(_catalogue),
        ),
      ),
      act: (bloc) async {
        bloc.add(WorkoutSummaryStarted(session: _session));
        await Future<void>.delayed(Duration.zero);
        bloc.add(const WorkoutSummaryRetryRequested());
      },
      expect: () => [_loading(), _error(), _loading(), _success()],
      verify: (_) => verify(() => repository.saveSession(_session)).called(2),
    );

    blocTest<WorkoutSummaryBloc, WorkoutSummaryState>(
      'retry that fails again returns to Error',
      setUp: () {
        stubNotYetSaved();
        stubSaveFails();
      },
      build: () => WorkoutSummaryBloc(
        repository: repository,
        saveSession: SaveWorkoutSessionUseCase(
          repository: repository,
          exerciseRepository: const FakeExerciseRepository(_catalogue),
        ),
      ),
      act: (bloc) async {
        bloc.add(WorkoutSummaryStarted(session: _session));
        await Future<void>.delayed(Duration.zero);
        bloc.add(const WorkoutSummaryRetryRequested());
      },
      expect: () => [_loading(), _error(), _loading(), _error()],
    );

    blocTest<WorkoutSummaryBloc, WorkoutSummaryState>(
      'retry finds the session already stored and does not write again',
      setUp: () {
        var lookups = 0;
        when(() => repository.getSessionById(any())).thenAnswer((_) async {
          lookups++;
          return lookups == 1 ? const Right(null) : Right(_session);
        });
        stubSaveFails();
      },
      build: () => WorkoutSummaryBloc(
        repository: repository,
        saveSession: SaveWorkoutSessionUseCase(
          repository: repository,
          exerciseRepository: const FakeExerciseRepository(_catalogue),
        ),
      ),
      act: (bloc) async {
        bloc.add(WorkoutSummaryStarted(session: _session));
        await Future<void>.delayed(Duration.zero);
        bloc.add(const WorkoutSummaryRetryRequested());
      },
      expect: () => [_loading(), _error(), _loading(), _success()],
      verify: (_) => verify(() => repository.saveSession(any())).called(1),
    );

    blocTest<WorkoutSummaryBloc, WorkoutSummaryState>(
      'retry before start is a no-op',
      build: () => WorkoutSummaryBloc(
        repository: repository,
        saveSession: SaveWorkoutSessionUseCase(
          repository: repository,
          exerciseRepository: const FakeExerciseRepository(_catalogue),
        ),
      ),
      act: (bloc) => bloc.add(const WorkoutSummaryRetryRequested()),
      expect: () => <WorkoutSummaryState>[],
    );
  });

  group('WorkoutSummaryBloc — validation failure', () {
    blocTest<WorkoutSummaryBloc, WorkoutSummaryState>(
      'an invalid log is not retryable',
      setUp: stubNotYetSaved,
      build: () => WorkoutSummaryBloc(
        repository: repository,
        saveSession: SaveWorkoutSessionUseCase(
          repository: repository,
          exerciseRepository: const FakeExerciseRepository([]),
        ),
      ),
      act: (bloc) => bloc.add(WorkoutSummaryStarted(session: _session)),
      expect: () => [
        _loading(),
        isA<WorkoutSummaryError>().having(
          (s) => s.isRetryable,
          'isRetryable',
          false,
        ),
      ],
    );

    blocTest<WorkoutSummaryBloc, WorkoutSummaryState>(
      'a storage failure stays retryable',
      setUp: () {
        stubNotYetSaved();
        stubSaveFails();
      },
      build: () => WorkoutSummaryBloc(
        repository: repository,
        saveSession: SaveWorkoutSessionUseCase(
          repository: repository,
          exerciseRepository: const FakeExerciseRepository(_catalogue),
        ),
      ),
      act: (bloc) => bloc.add(WorkoutSummaryStarted(session: _session)),
      expect: () => [
        _loading(),
        isA<WorkoutSummaryError>().having(
          (s) => s.isRetryable,
          'isRetryable',
          true,
        ),
      ],
    );
  });
}
