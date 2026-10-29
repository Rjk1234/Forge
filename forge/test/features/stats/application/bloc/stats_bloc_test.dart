import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forge/core/exceptions/app_exception.dart';
import 'package:forge/features/stats/application/bloc/stats_bloc.dart';
import 'package:forge/features/stats/application/bloc/stats_event.dart';
import 'package:forge/features/stats/application/bloc/stats_state.dart';
import 'package:forge/features/stats/application/use_cases/get_statistics_use_case.dart';
import 'package:forge/features/stats/domain/entities/stats_data.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';

class _MockUseCase extends Mock implements GetStatisticsUseCase {}

const _stats = StatsData(
  totalWorkoutsCompleted: 2,
  totalVolumeKg: 100,
  totalDurationSec: 7200,
  avgDurationSec: 3600,
);

void main() {
  late _MockUseCase useCase;

  setUp(() {
    useCase = _MockUseCase();
  });

  StatsBloc build() => StatsBloc(getStatistics: useCase);

  test('starts in Initial', () {
    expect(build().state, const StatsInitial());
  });

  blocTest<StatsBloc, StatsState>(
    'emits Loading then Loaded',
    setUp: () => when(
      () => useCase(),
    ).thenAnswer((_) async => const Right((stats: _stats, exercises: []))),
    build: build,
    act: (bloc) => bloc.add(const StatsLoadRequested()),
    expect: () => [
      const StatsLoading(),
      const StatsLoaded(stats: _stats, exercises: []),
    ],
  );

  blocTest<StatsBloc, StatsState>(
    'emits Loading then Error on failure',
    setUp: () => when(
      () => useCase(),
    ).thenAnswer((_) async => Left(CacheException(message: 'boom'))),
    build: build,
    act: (bloc) => bloc.add(const StatsLoadRequested()),
    expect: () => [const StatsLoading(), const StatsError()],
  );

  blocTest<StatsBloc, StatsState>(
    'retry after Error recovers',
    setUp: () {
      var calls = 0;
      when(() => useCase()).thenAnswer((_) async {
        calls++;
        return calls == 1
            ? Left(CacheException(message: 'boom'))
            : const Right((stats: _stats, exercises: []));
      });
    },
    build: build,
    act: (bloc) async {
      bloc.add(const StatsLoadRequested());
      await Future<void>.delayed(Duration.zero);
      bloc.add(const StatsLoadRequested());
    },
    expect: () => [
      const StatsLoading(),
      const StatsError(),
      const StatsLoading(),
      const StatsLoaded(stats: _stats, exercises: []),
    ],
  );

  test('a reload requested during a load runs right after it', () async {
    final first = Completer<Either<AppException, StatsSummary>>();
    var calls = 0;
    when(() => useCase()).thenAnswer((_) {
      calls++;
      return calls == 1
          ? first.future
          : Future.value(const Right((stats: _stats, exercises: [])));
    });
    final bloc = build();
    final states = <StatsState>[];
    final sub = bloc.stream.listen(states.add);

    bloc.add(const StatsLoadRequested());
    await Future<void>.delayed(Duration.zero);
    bloc.add(const StatsLoadRequested());
    await Future<void>.delayed(Duration.zero);
    first.complete(const Right((stats: _stats, exercises: [])));
    await Future<void>.delayed(const Duration(milliseconds: 10));

    expect(calls, 2);
    expect(states.last, const StatsLoaded(stats: _stats, exercises: []));
    await sub.cancel();
    await bloc.close();
  });
}
