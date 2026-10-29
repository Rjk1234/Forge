import 'package:forge/core/exceptions/app_exception.dart';
import 'package:forge/features/exercise/domain/entities/exercise.dart';
import 'package:forge/features/exercise/domain/repositories/exercise_repository.dart';
import 'package:forge/features/workout_plan/domain/entities/plan_exercise.dart';
import 'package:forge/features/workout_plan/domain/entities/workout_plan_detail.dart';
import 'package:forge/features/workout_plan/domain/repositories/workout_plan_repository.dart';
import 'package:forge/features/workout_plan/domain/validation/plan_validator.dart';
import 'package:forge/features/workout_plan/domain/validation/plan_violation.dart';
import 'package:fpdart/fpdart.dart';

/// Saves a plan only when it satisfies every business rule: valid name and
/// numbers, and every planned exercise exists in the exercise catalogue.
class SaveWorkoutPlanUseCase {
  const SaveWorkoutPlanUseCase({
    required this._repository,
    required this._exerciseRepository,
    this._validator = const PlanValidator(),
  });

  final WorkoutPlanRepository _repository;
  final ExerciseRepository _exerciseRepository;
  final PlanValidator _validator;

  Future<Either<AppException, WorkoutPlanDetail>> call(
    WorkoutPlanDetail plan,
  ) async {
    final violations = _validator.validate(plan);
    if (violations.isNotEmpty) return Left(_toException(violations));

    final catalogue = await _exerciseRepository.getExercises();
    return catalogue.fold<Future<Either<AppException, WorkoutPlanDetail>>>(
      (failure) async => Left(failure),
      (exercises) => _saveChecked(plan, exercises),
    );
  }

  Future<Either<AppException, WorkoutPlanDetail>> _saveChecked(
    WorkoutPlanDetail plan,
    List<Exercise> catalogue,
  ) {
    final checked = _checkAgainstCatalogue(plan, catalogue);
    return checked.fold<Future<Either<AppException, WorkoutPlanDetail>>>(
      (violations) async => Left(_toException(violations)),
      _repository.savePlan,
    );
  }

  /// Verifies every exercise exists with the same type and refreshes the
  /// stored name from the catalogue.
  Either<List<PlanViolation>, WorkoutPlanDetail> _checkAgainstCatalogue(
    WorkoutPlanDetail plan,
    List<Exercise> catalogue,
  ) {
    final byId = {for (final exercise in catalogue) exercise.id: exercise};
    final violations = <PlanViolation>[];
    final synced = <PlanExercise>[];

    for (var i = 0; i < plan.exercises.length; i++) {
      final planned = plan.exercises[i];
      final known = byId[planned.exerciseId];
      if (known == null || known.type != planned.type) {
        violations.add(
          PlanViolation(PlanViolationType.unknownExercise, exerciseIndex: i),
        );
        continue;
      }
      synced.add(planned.copyWithName(known.name));
    }
    if (violations.isNotEmpty) return Left(violations);

    return Right(
      WorkoutPlanDetail(
        id: plan.id,
        name: plan.name.trim(),
        exercises: synced,
        createdAt: plan.createdAt,
      ),
    );
  }

  ValidationException _toException(List<PlanViolation> violations) {
    return ValidationException(
      message: 'Workout plan is invalid: ${violations.join(', ')}',
      code: violations.first.type.name,
    );
  }
}
