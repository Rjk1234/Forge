import 'package:forge/core/exceptions/app_exception.dart';
import 'package:forge/features/workout_plan/domain/entities/workout_plan.dart';
import 'package:forge/features/workout_plan/domain/entities/workout_plan_detail.dart';
import 'package:fpdart/fpdart.dart';

abstract class WorkoutPlanRepository {
  Future<Either<AppException, List<WorkoutPlan>>> getAllPlans();

  Future<Either<AppException, WorkoutPlanDetail>> getPlanById(String planId);

  Future<Either<AppException, WorkoutPlanDetail>> savePlan(
    WorkoutPlanDetail plan,
  );

  Future<Either<AppException, void>> deletePlan(String planId);
}
