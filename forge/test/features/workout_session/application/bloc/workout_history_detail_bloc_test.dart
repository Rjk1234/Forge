import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forge/core/exceptions/app_exception.dart';
import 'package:forge/features/workout_session/application/bloc/workout_history_detail_bloc.dart';
import 'package:forge/features/workout_session/application/bloc/workout_history_detail_event.dart';
import 'package:forge/features/workout_session/application/bloc/workout_history_detail_state.dart';
import 'package:forge/features/workout_session/application/use_cases/get_workout_history_detail_use_case.dart';
import 'package:forge/features/workout_session/domain/entities/workout_session.dart';
import 'package:forge/features/workout_session/domain/repositories/workout_session_repository.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';

class _MockRepository extends Mock implements WorkoutSessionRepository {}

final _session = WorkoutSession(
  sessionId: 's1',
  planId: 'p',
  planName: 'Push Day',
  completedAt: DateTime(2026, 9, 7, 19),
  startedAt: DateTime(2026, 9, 7, 18),
  sessionDurationSec: 3600,
  sessionExercises: const [],
);

void main() {
  late _MockRepository repository;

  setUpAll(() {
    registerFallbackValue(_session);
  });

  setUp(() {
    repository = _MockRepository();
  });

  WorkoutHistoryDetailBloc build() => WorkoutHistoryDetailBloc(
    getDetail: GetWorkoutHistoryDetailUseCase(repository),
  );

  const request = WorkoutHistoryDetailLoadRequested(sessionId: 's1');

  test('starts in Initial', () {
    expect(build().state, const WorkoutHistoryDetailInitial());
  });

  blocTest<WorkoutHistoryDetailBloc, WorkoutHistoryDetailState>(
    'emits Loading then Success with the stored session',
    setUp: () => when(
      () => repository.getSessionById('s1'),
    ).thenAnswer((_) async => Right(_session)),
    build: build,
    act: (bloc) => bloc.add(request),
    expect: () => [
      const WorkoutHistoryDetailLoading(),
      WorkoutHistoryDetailSuccess(session: _session),
    ],
  );

  blocTest<WorkoutHistoryDetailBloc, WorkoutHistoryDetailState>(
    'emits Error with user-facing copy, never the raw exception text',
    setUp: () => when(() => repository.getSessionById('s1')).thenAnswer(
      (_) async => Left(CacheException(message: 'raw database text')),
    ),
    build: build,
    act: (bloc) => bloc.add(request),
    expect: () => [
      const WorkoutHistoryDetailLoading(),
      const WorkoutHistoryDetailError(),
    ],
  );

  blocTest<WorkoutHistoryDetailBloc, WorkoutHistoryDetailState>(
    'a missing session is an Error',
    setUp: () => when(
      () => repository.getSessionById('s1'),
    ).thenAnswer((_) async => const Right(null)),
    build: build,
    act: (bloc) => bloc.add(request),
    expect: () => [
      const WorkoutHistoryDetailLoading(),
      const WorkoutHistoryDetailError(),
    ],
  );

  blocTest<WorkoutHistoryDetailBloc, WorkoutHistoryDetailState>(
    'retry re-enters Loading and can succeed',
    setUp: () {
      var calls = 0;
      when(() => repository.getSessionById('s1')).thenAnswer((_) async {
        calls++;
        return calls == 1
            ? Left(CacheException(message: 'boom'))
            : Right(_session);
      });
    },
    build: build,
    act: (bloc) async {
      bloc.add(request);
      await Future<void>.delayed(Duration.zero);
      bloc.add(request);
    },
    expect: () => [
      const WorkoutHistoryDetailLoading(),
      const WorkoutHistoryDetailError(),
      const WorkoutHistoryDetailLoading(),
      WorkoutHistoryDetailSuccess(session: _session),
    ],
  );

  blocTest<WorkoutHistoryDetailBloc, WorkoutHistoryDetailState>(
    'is read-only: never saves or deletes',
    setUp: () => when(
      () => repository.getSessionById('s1'),
    ).thenAnswer((_) async => Right(_session)),
    build: build,
    act: (bloc) => bloc.add(request),
    verify: (_) {
      verifyNever(() => repository.saveSession(any()));
      verifyNever(() => repository.deleteSession(any()));
    },
  );

  test('a reload requested during a load is served afterwards', () async {
    final first = Completer<Either<AppException, WorkoutSession?>>();
    var calls = 0;
    when(() => repository.getSessionById('s1')).thenAnswer((_) {
      calls++;
      return calls == 1 ? first.future : Future.value(Right(_session));
    });
    final bloc = build()..add(request);
    await Future<void>.delayed(Duration.zero);

    bloc.add(request);
    await Future<void>.delayed(Duration.zero);
    first.complete(Right(_session));
    await bloc.stream.firstWhere((s) => s is WorkoutHistoryDetailSuccess);
    await Future<void>.delayed(Duration.zero);

    verify(() => repository.getSessionById('s1')).called(2);
    await bloc.close();
  });
}
