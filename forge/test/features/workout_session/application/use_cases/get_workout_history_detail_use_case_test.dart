import 'package:flutter_test/flutter_test.dart';
import 'package:forge/core/exceptions/app_exception.dart';
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
  late GetWorkoutHistoryDetailUseCase useCase;

  setUp(() {
    repository = _MockRepository();
    useCase = GetWorkoutHistoryDetailUseCase(repository);
  });

  test('returns the stored session', () async {
    when(
      () => repository.getSessionById('s1'),
    ).thenAnswer((_) async => Right(_session));

    final result = await useCase('s1');

    expect(result, Right<AppException, WorkoutSession>(_session));
  });

  test('a missing session is a failure', () async {
    when(
      () => repository.getSessionById('s1'),
    ).thenAnswer((_) async => const Right(null));

    final result = await useCase('s1');

    expect(result.isLeft(), isTrue);
    result.match((error) => expect(error, isA<CacheException>()), (_) {});
  });

  test('passes a read failure through', () async {
    final failure = CacheException(message: 'read failed');
    when(
      () => repository.getSessionById('s1'),
    ).thenAnswer((_) async => Left(failure));

    final result = await useCase('s1');

    expect(result, Left<AppException, WorkoutSession>(failure));
  });
}
