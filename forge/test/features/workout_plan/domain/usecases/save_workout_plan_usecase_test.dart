import 'package:flutter_test/flutter_test.dart';
import 'package:forge/core/enums/exercise_type.dart';
import 'package:forge/core/exceptions/app_exception.dart';
import 'package:forge/features/exercise/domain/entities/exercise.dart';
import 'package:forge/features/workout_plan/domain/entities/plan_exercise.dart';
import 'package:forge/features/workout_plan/domain/entities/workout_plan.dart';
import 'package:forge/features/workout_plan/domain/entities/workout_plan_detail.dart';
import 'package:forge/features/workout_plan/domain/repositories/workout_plan_repository.dart';
import 'package:forge/features/workout_plan/domain/usecases/save_workout_plan_usecase.dart';
import 'package:fpdart/fpdart.dart';

import '../../../../helpers/fake_exercise_repository.dart';

class _RecordingRepository implements WorkoutPlanRepository {
  final List<WorkoutPlanDetail> saved = [];

  @override
  Future<Either<AppException, WorkoutPlanDetail>> savePlan(
    WorkoutPlanDetail plan,
  ) async {
    saved.add(plan);
    return Right(plan);
  }

  @override
  Future<Either<AppException, List<WorkoutPlan>>> getAllPlans() async =>
      const Right([]);

  @override
  Future<Either<AppException, WorkoutPlanDetail>> getPlanById(String id) =>
      throw UnimplementedError();

  @override
  Future<Either<AppException, void>> deletePlan(String planId) =>
      throw UnimplementedError();
}

const _bench = Exercise(
  id: 'ex_bench',
  name: 'Bench Press',
  type: ExerciseType.weighted,
);

WorkoutPlanDetail _plan({
  String name = 'Push Day',
  String exerciseId = 'ex_bench',
  ExerciseType type = ExerciseType.weighted,
  String exerciseName = 'old name',
}) => WorkoutPlanDetail(
  id: 'p1',
  name: name,
  createdAt: DateTime(2026, 1, 1),
  exercises: [
    PlanExercise(
      exerciseId: exerciseId,
      exerciseName: exerciseName,
      type: type,
      targetSets: 3,
      restPeriodSec: 60,
      targetRepetitions: 10,
      targetWeight: type == ExerciseType.weighted ? 60 : null,
    ),
  ],
);

SaveWorkoutPlanUseCase _useCase(
  _RecordingRepository repository, {
  List<Exercise> catalogue = const [_bench],
  AppException? catalogueFailure,
}) => SaveWorkoutPlanUseCase(
  repository: repository,
  exerciseRepository: FakeExerciseRepository(
    catalogue,
    failure: catalogueFailure,
  ),
);

void main() {
  test(
    'saves a valid plan, trimming the name and refreshing exercise names',
    () async {
      final repository = _RecordingRepository();

      final result = await _useCase(repository)(_plan(name: '  Push Day  '));

      expect(result.isRight(), isTrue);
      expect(repository.saved.single.name, 'Push Day');
      expect(
        repository.saved.single.exercises.single.exerciseName,
        'Bench Press',
      );
    },
  );

  test('rejects a blank name without touching the repository', () async {
    final repository = _RecordingRepository();

    final result = await _useCase(repository)(_plan(name: '  '));

    expect(result.isLeft(), isTrue);
    result.fold((error) {
      expect(error, isA<ValidationException>());
      expect(error.code, 'nameInvalid');
    }, (_) => fail('expected a failure'));
    expect(repository.saved, isEmpty);
  });

  test('rejects an exercise that is not in the catalogue', () async {
    final repository = _RecordingRepository();

    final result = await _useCase(repository)(_plan(exerciseId: 'ex_unknown'));

    result.fold(
      (error) => expect(error.code, 'unknownExercise'),
      (_) => fail('expected a failure'),
    );
    expect(repository.saved, isEmpty);
  });

  test('rejects an exercise whose type differs from the catalogue', () async {
    final repository = _RecordingRepository();

    final result = await _useCase(repository)(
      _plan(type: ExerciseType.bodyweight),
    );

    expect(result.isLeft(), isTrue);
    expect(repository.saved, isEmpty);
  });

  test('passes a catalogue read failure through and saves nothing', () async {
    final repository = _RecordingRepository();
    final failure = CacheException(message: 'catalogue unavailable');

    final result = await _useCase(repository, catalogueFailure: failure)(
      _plan(),
    );

    result.fold(
      (error) => expect(error, same(failure)),
      (_) => fail('expected a failure'),
    );
    expect(repository.saved, isEmpty);
  });

  test('a plan with no exercises is rejected and never stored', () async {
    final repository = _RecordingRepository();
    final plan = WorkoutPlanDetail(
      id: 'p1',
      name: 'Empty',
      createdAt: DateTime(2026, 1, 1),
      exercises: const [],
    );

    final result = await _useCase(repository, catalogue: const [])(plan);

    expect(result.isLeft(), isTrue);
    expect(repository.saved, isEmpty);
  });
}
