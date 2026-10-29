import 'package:forge/core/exceptions/app_exception.dart';
import 'package:forge/features/workout_plan/domain/entities/workout_plan_detail.dart';
import 'package:forge/features/workout_plan/domain/repositories/workout_plan_repository.dart';
import 'package:fpdart/fpdart.dart';

class GetWorkoutPlanByIdUseCase {
  const GetWorkoutPlanByIdUseCase(this._repository);

  final WorkoutPlanRepository _repository;

  Future<Either<AppException, WorkoutPlanDetail>> call(String planId) =>
      _repository.getPlanById(planId);
}
