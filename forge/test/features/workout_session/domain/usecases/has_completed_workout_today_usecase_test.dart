import 'package:flutter_test/flutter_test.dart';
import 'package:forge/core/exceptions/app_exception.dart';
import 'package:forge/features/workout_session/domain/repositories/workout_session_repository.dart';
import 'package:forge/features/workout_session/domain/usecases/has_completed_workout_today_usecase.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/session_builders.dart';

class _MockSessionRepository extends Mock implements WorkoutSessionRepository {}

void main() {
  late _MockSessionRepository repository;
  late HasCompletedWorkoutTodayUseCase useCase;

  setUp(() {
    repository = _MockSessionRepository();
    useCase = HasCompletedWorkoutTodayUseCase(
      repository,
      now: () => DateTime(2026, 10, 23, 12),
    );
  });

  test('is true when the plan has a completed session today', () async {
    when(() => repository.getSessionsByPlanId('p1')).thenAnswer(
      (_) async => Right([
        sessionOf(planId: 'p1', startedAt: DateTime(2026, 10, 23, 7)),
      ]),
    );

    expect((await useCase('p1')).getOrElse((_) => false), isTrue);
  });

  test('is false when the only session was yesterday', () async {
    when(() => repository.getSessionsByPlanId('p1')).thenAnswer(
      (_) async => Right([
        sessionOf(planId: 'p1', startedAt: DateTime(2026, 10, 22, 7)),
      ]),
    );

    expect((await useCase('p1')).getOrElse((_) => true), isFalse);
  });

  test('passes a storage failure through', () async {
    when(
      () => repository.getSessionsByPlanId('p1'),
    ).thenAnswer((_) async => Left(CacheException(message: 'boom')));

    expect((await useCase('p1')).isLeft(), isTrue);
  });
}
