import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forge/core/enums/exercise_type.dart';
import 'package:forge/core/exceptions/app_exception.dart';
import 'package:forge/features/personal_bests/application/bloc/pb_bloc.dart';
import 'package:forge/features/personal_bests/application/bloc/pb_event.dart';
import 'package:forge/features/personal_bests/application/bloc/pb_state.dart';
import 'package:forge/features/personal_bests/application/use_cases/get_personal_bests_use_case.dart';
import 'package:forge/features/personal_bests/domain/entities/personal_best_record.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';

class _MockUseCase extends Mock implements GetPersonalBestsUseCase {}

final _record = PersonalBestRecord(
  exerciseName: 'Bench',
  type: ExerciseType.weighted,
  bestDate: DateTime(2026, 8, 31),
  bestWeight: 65,
);

void main() {
  late _MockUseCase useCase;

  setUp(() {
    useCase = _MockUseCase();
  });

  PbBloc build() => PbBloc(getPersonalBests: useCase);

  test('starts in Initial', () {
    expect(build().state, const PbInitial());
  });

  blocTest<PbBloc, PbState>(
    'emits Loading then Loaded',
    setUp: () =>
        when(() => useCase()).thenAnswer((_) async => Right([_record])),
    build: build,
    act: (bloc) => bloc.add(const PbLoadRequested()),
    expect: () => [
      const PbLoading(),
      PbLoaded(records: [_record]),
    ],
  );

  blocTest<PbBloc, PbState>(
    'an empty result is Loaded, not Error',
    setUp: () => when(() => useCase()).thenAnswer((_) async => const Right([])),
    build: build,
    act: (bloc) => bloc.add(const PbLoadRequested()),
    expect: () => [const PbLoading(), const PbLoaded(records: [])],
  );

  blocTest<PbBloc, PbState>(
    'a failure emits Error',
    setUp: () => when(
      () => useCase(),
    ).thenAnswer((_) async => Left(CacheException(message: 'boom'))),
    build: build,
    act: (bloc) => bloc.add(const PbLoadRequested()),
    expect: () => [const PbLoading(), const PbError()],
  );

  blocTest<PbBloc, PbState>(
    'retry from Error goes back through Loading',
    setUp: () {
      var calls = 0;
      when(() => useCase()).thenAnswer((_) async {
        calls++;
        return calls == 1
            ? Left(CacheException(message: 'boom'))
            : Right([_record]);
      });
    },
    build: build,
    act: (bloc) async {
      bloc.add(const PbLoadRequested());
      await Future<void>.delayed(Duration.zero);
      bloc.add(const PbLoadRequested());
    },
    expect: () => [
      const PbLoading(),
      const PbError(),
      const PbLoading(),
      PbLoaded(records: [_record]),
    ],
  );

  test('a reload requested during a load runs right after it', () async {
    final first = Completer<Either<AppException, List<PersonalBestRecord>>>();
    var calls = 0;
    when(() => useCase()).thenAnswer((_) {
      calls++;
      return calls == 1
          ? first.future
          : Future.value(Right(const <PersonalBestRecord>[]));
    });
    final bloc = build();
    final states = <PbState>[];
    final sub = bloc.stream.listen(states.add);

    bloc.add(const PbLoadRequested());
    await Future<void>.delayed(Duration.zero);
    bloc.add(const PbLoadRequested());
    await Future<void>.delayed(Duration.zero);
    first.complete(Right(const <PersonalBestRecord>[]));
    await Future<void>.delayed(const Duration(milliseconds: 10));

    expect(calls, 2);
    expect(states.last, const PbLoaded(records: []));
    await sub.cancel();
    await bloc.close();
  });
}
