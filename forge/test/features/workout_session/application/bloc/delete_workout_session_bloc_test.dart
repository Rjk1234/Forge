import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forge/core/exceptions/app_exception.dart';
import 'package:forge/features/workout_session/application/bloc/delete_workout_session_bloc.dart';
import 'package:forge/features/workout_session/application/bloc/delete_workout_session_event.dart';
import 'package:forge/features/workout_session/application/bloc/delete_workout_session_state.dart';
import 'package:forge/features/workout_session/domain/usecases/delete_workout_session_usecase.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';

class _MockDelete extends Mock implements DeleteWorkoutSessionUseCase {}

void main() {
  late _MockDelete delete;

  setUp(() => delete = _MockDelete());

  DeleteWorkoutSessionBloc build() =>
      DeleteWorkoutSessionBloc(deleteWorkoutSession: delete);

  const confirmed = DeleteWorkoutSessionConfirmed(sessionId: 's1');

  blocTest<DeleteWorkoutSessionBloc, DeleteWorkoutSessionState>(
    'emits deleting then success',
    setUp: () =>
        when(() => delete('s1')).thenAnswer((_) async => const Right(null)),
    build: build,
    act: (bloc) => bloc.add(confirmed),
    expect: () => const [
      DeleteWorkoutSessionDeleting(),
      DeleteWorkoutSessionSuccess(),
    ],
  );

  blocTest<DeleteWorkoutSessionBloc, DeleteWorkoutSessionState>(
    'emits deleting then failure when the delete fails',
    setUp: () => when(
      () => delete('s1'),
    ).thenAnswer((_) async => Left(CacheException(message: 'disk'))),
    build: build,
    act: (bloc) => bloc.add(confirmed),
    expect: () => const [
      DeleteWorkoutSessionDeleting(),
      DeleteWorkoutSessionFailure(),
    ],
  );

  test('retry after a failure can succeed', () async {
    var calls = 0;
    when(() => delete('s1')).thenAnswer((_) async {
      calls++;
      return calls == 1
          ? Left<AppException, void>(CacheException(message: 'disk'))
          : const Right<AppException, void>(null);
    });
    final bloc = build();

    bloc.add(confirmed);
    await bloc.stream.firstWhere((s) => s is DeleteWorkoutSessionFailure);
    bloc.add(confirmed);
    await bloc.stream.firstWhere((s) => s is DeleteWorkoutSessionSuccess);

    expect(calls, 2);
    await bloc.close();
  });
}
