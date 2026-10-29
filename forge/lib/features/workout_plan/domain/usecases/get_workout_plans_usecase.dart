import 'package:forge/core/exceptions/app_exception.dart';
import 'package:forge/features/workout_plan/domain/entities/workout_plan.dart';
import 'package:forge/features/workout_plan/domain/repositories/workout_plan_repository.dart';
import 'package:fpdart/fpdart.dart';

class GetWorkoutPlansUseCase {
  const GetWorkoutPlansUseCase({required this.repository});

  final WorkoutPlanRepository repository;

  Future<Either<AppException, List<WorkoutPlan>>> call() =>
      repository.getAllPlans();
}
