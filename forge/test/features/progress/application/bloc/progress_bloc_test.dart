import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forge/core/enums/exercise_type.dart';
import 'package:forge/core/exceptions/app_exception.dart';
import 'package:forge/features/progress/application/bloc/progress_bloc.dart';
import 'package:forge/features/progress/application/bloc/progress_event.dart';
import 'package:forge/features/progress/application/bloc/progress_state.dart';
import 'package:forge/features/progress/application/use_cases/get_exercise_progress_data_use_case.dart';
import 'package:forge/features/progress/domain/entities/exercise_metrics.dart';
import 'package:forge/features/progress/domain/entities/exercise_progress_data.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';

class _MockUseCase extends Mock implements GetExerciseProgressDataUseCase {}

ExerciseProgressData _exercise(String name) => ExerciseProgressData(
  exerciseName: name,
  type: ExerciseType.bodyweight,
  totalValidSessions: 2,
  sessionDataPoints: const [],
  latestMetrics: const BodyweightMetrics(
    totalSets: 1,
    bestReps: 1,
    totalReps: 1,
  ),
  latestWorkoutDurationSec: 0,
);

void main() {
  late _MockUseCase useCase;
  final bench = _exercise('Bench');
  final squat = _exercise('Squat');

  setUp(() {
    useCase = _MockUseCase();
  });

  ProgressBloc build() => ProgressBloc(getProgressData: useCase);

  test('starts in Initial', () {
    expect(build().state, const ProgressInitial());
  });

  blocTest<ProgressBloc, ProgressState>(
    'load selects the first exercise',
    setUp: () =>
        when(() => useCase()).thenAnswer((_) async => Right([bench, squat])),
    build: build,
    act: (bloc) => bloc.add(const ProgressLoadRequested()),
    expect: () => [
      const ProgressLoading(),
      ProgressLoaded(exercises: [bench, squat], selectedExerciseName: 'Bench'),
    ],
  );

  blocTest<ProgressBloc, ProgressState>(
    'load with no data is Loaded with an empty list, not Error',
    setUp: () => when(() => useCase()).thenAnswer((_) async => const Right([])),
    build: build,
    act: (bloc) => bloc.add(const ProgressLoadRequested()),
    expect: () => [
      const ProgressLoading(),
      const ProgressLoaded(exercises: [], selectedExerciseName: ''),
    ],
  );

  blocTest<ProgressBloc, ProgressState>(
    'a read failure emits Error',
    setUp: () => when(
      () => useCase(),
    ).thenAnswer((_) async => Left(CacheException(message: 'boom'))),
    build: build,
    act: (bloc) => bloc.add(const ProgressLoadRequested()),
    expect: () => [const ProgressLoading(), const ProgressError()],
  );

  blocTest<ProgressBloc, ProgressState>(
    'selecting a chip changes the selection without reading storage',
    setUp: () =>
        when(() => useCase()).thenAnswer((_) async => Right([bench, squat])),
    build: build,
    act: (bloc) async {
      bloc.add(const ProgressLoadRequested());
      await Future<void>.delayed(Duration.zero);
      bloc.add(const ProgressExerciseSelected(exerciseName: 'Squat'));
    },
    skip: 2,
    expect: () => [
      ProgressLoaded(exercises: [bench, squat], selectedExerciseName: 'Squat'),
    ],
    verify: (_) => verify(() => useCase()).called(1),
  );

  blocTest<ProgressBloc, ProgressState>(
    'selecting a chip while in Error is ignored',
    setUp: () => when(
      () => useCase(),
    ).thenAnswer((_) async => Left(CacheException(message: 'boom'))),
    build: build,
    act: (bloc) async {
      bloc.add(const ProgressLoadRequested());
      await Future<void>.delayed(Duration.zero);
      bloc.add(const ProgressExerciseSelected(exerciseName: 'Squat'));
    },
    expect: () => [const ProgressLoading(), const ProgressError()],
  );

  blocTest<ProgressBloc, ProgressState>(
    'retry after Error can recover',
    setUp: () {
      var calls = 0;
      when(() => useCase()).thenAnswer((_) async {
        calls++;
        return calls == 1
            ? Left(CacheException(message: 'boom'))
            : Right([bench]);
      });
    },
    build: build,
    act: (bloc) async {
      bloc.add(const ProgressLoadRequested());
      await Future<void>.delayed(Duration.zero);
      bloc.add(const ProgressLoadRequested());
    },
    expect: () => [
      const ProgressLoading(),
      const ProgressError(),
      const ProgressLoading(),
      ProgressLoaded(exercises: [bench], selectedExerciseName: 'Bench'),
    ],
  );

  test('a reload requested during a load runs right after it', () async {
    final first = Completer<Either<AppException, List<ExerciseProgressData>>>();
    var calls = 0;
    when(() => useCase()).thenAnswer((_) {
      calls++;
      return calls == 1 ? first.future : Future.value(Right([bench]));
    });
    final bloc = build();
    final states = <ProgressState>[];
    final sub = bloc.stream.listen(states.add);

    bloc.add(const ProgressLoadRequested());
    await Future<void>.delayed(Duration.zero);
    bloc.add(const ProgressLoadRequested());
    await Future<void>.delayed(Duration.zero);
    first.complete(Right([bench]));
    await Future<void>.delayed(const Duration(milliseconds: 10));

    expect(calls, 2);
    expect(
      states.last,
      ProgressLoaded(exercises: [bench], selectedExerciseName: 'Bench'),
    );
    await sub.cancel();
    await bloc.close();
  });
}
