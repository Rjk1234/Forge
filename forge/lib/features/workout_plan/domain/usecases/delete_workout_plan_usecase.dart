import 'package:forge/core/exceptions/app_exception.dart';
import 'package:forge/features/workout_plan/domain/repositories/workout_plan_repository.dart';
import 'package:fpdart/fpdart.dart';

class DeleteWorkoutPlanUseCase {
  const DeleteWorkoutPlanUseCase(this._repository);

  final WorkoutPlanRepository _repository;

  Future<Either<AppException, void>> call(String planId) =>
      _repository.deletePlan(planId);
}
