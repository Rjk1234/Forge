import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forge/core/exceptions/app_exception.dart';
import 'package:forge/features/workout_session/application/bloc/workout_history_bloc.dart';
import 'package:forge/features/workout_session/application/bloc/workout_history_event.dart';
import 'package:forge/features/workout_session/application/bloc/workout_history_state.dart';
import 'package:forge/features/workout_session/application/models/history_month_group.dart';
import 'package:forge/features/workout_session/application/use_cases/get_workout_history_use_case.dart';
import 'package:forge/features/workout_session/domain/entities/workout_session.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';

class _MockUseCase extends Mock implements GetWorkoutHistoryUseCase {}

WorkoutSession _session(String id, DateTime startedAt) => WorkoutSession(
  sessionId: id,
  planId: 'p',
  planName: 'Plan $id',
  completedAt: startedAt.add(const Duration(hours: 1)),
  startedAt: startedAt,
  sessionDurationSec: 3600,
  sessionExercises: const [],
);

void main() {
  late _MockUseCase useCase;

  setUp(() {
    useCase = _MockUseCase();
  });

  WorkoutHistoryBloc build() => WorkoutHistoryBloc(getWorkoutHistory: useCase);

  final sept7 = _session('sept7', DateTime(2026, 9, 7, 18));
  final sept3 = _session('sept3', DateTime(2026, 9, 3, 18));
  final aug31 = _session('aug31', DateTime(2026, 8, 31, 18));

  group('WorkoutHistoryBloc', () {
    blocTest<WorkoutHistoryBloc, WorkoutHistoryState>(
      'groups sessions from different months under separate labels',
      setUp: () =>
          when(() => useCase()).thenAnswer((_) async => Right([sept7, aug31])),
      build: build,
      act: (bloc) => bloc.add(const WorkoutHistoryLoadRequested()),
      expect: () => [
        const WorkoutHistoryLoading(),
        WorkoutHistorySuccess(
          groups: [
            HistoryMonthGroup(label: 'September 2026', sessions: [sept7]),
            HistoryMonthGroup(label: 'August 2026', sessions: [aug31]),
          ],
        ),
      ],
    );

    blocTest<WorkoutHistoryBloc, WorkoutHistoryState>(
      'keeps same-month sessions together in newest-first order',
      setUp: () =>
          when(() => useCase()).thenAnswer((_) async => Right([sept7, sept3])),
      build: build,
      act: (bloc) => bloc.add(const WorkoutHistoryLoadRequested()),
      expect: () => [
        const WorkoutHistoryLoading(),
        WorkoutHistorySuccess(
          groups: [
            HistoryMonthGroup(
              label: 'September 2026',
              sessions: [sept7, sept3],
            ),
          ],
        ),
      ],
    );

    blocTest<WorkoutHistoryBloc, WorkoutHistoryState>(
      'an empty result is Empty, not Error',
      setUp: () =>
          when(() => useCase()).thenAnswer((_) async => const Right([])),
      build: build,
      act: (bloc) => bloc.add(const WorkoutHistoryLoadRequested()),
      expect: () => [
        const WorkoutHistoryLoading(),
        const WorkoutHistoryEmpty(),
      ],
    );

    blocTest<WorkoutHistoryBloc, WorkoutHistoryState>(
      'a read failure is Error, not Empty, with user-facing copy',
      setUp: () => when(
        () => useCase(),
      ).thenAnswer((_) async => Left(CacheException(message: 'boom'))),
      build: build,
      act: (bloc) => bloc.add(const WorkoutHistoryLoadRequested()),
      expect: () => [
        const WorkoutHistoryLoading(),
        const WorkoutHistoryError(),
      ],
    );

    blocTest<WorkoutHistoryBloc, WorkoutHistoryState>(
      'retry after a failure can succeed',
      setUp: () {
        var calls = 0;
        when(() => useCase()).thenAnswer((_) async {
          calls++;
          return calls == 1
              ? Left(CacheException(message: 'boom'))
              : Right([sept7]);
        });
      },
      build: build,
      act: (bloc) async {
        bloc.add(const WorkoutHistoryLoadRequested());
        await Future<void>.delayed(Duration.zero);
        bloc.add(const WorkoutHistoryLoadRequested());
      },
      expect: () => [
        const WorkoutHistoryLoading(),
        const WorkoutHistoryError(),
        const WorkoutHistoryLoading(),
        WorkoutHistorySuccess(
          groups: [
            HistoryMonthGroup(label: 'September 2026', sessions: [sept7]),
          ],
        ),
      ],
    );

    blocTest<WorkoutHistoryBloc, WorkoutHistoryState>(
      'retry that fails again stays on Error',
      setUp: () => when(
        () => useCase(),
      ).thenAnswer((_) async => Left(CacheException(message: 'boom'))),
      build: build,
      act: (bloc) async {
        bloc.add(const WorkoutHistoryLoadRequested());
        await Future<void>.delayed(Duration.zero);
        bloc.add(const WorkoutHistoryLoadRequested());
      },
      expect: () => [
        const WorkoutHistoryLoading(),
        const WorkoutHistoryError(),
        const WorkoutHistoryLoading(),
        const WorkoutHistoryError(),
      ],
    );
  });

  test('HistoryMonthGroup compares by label and sessions', () {
    expect(
      HistoryMonthGroup(label: 'September 2026', sessions: [sept7]),
      HistoryMonthGroup(label: 'September 2026', sessions: [sept7]),
    );
  });
}
