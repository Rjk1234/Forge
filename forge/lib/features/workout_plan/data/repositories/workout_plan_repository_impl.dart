import 'package:forge/core/exceptions/app_exception.dart';
import 'package:forge/features/workout_plan/data/datasources/workout_plan_local_data_source.dart';
import 'package:forge/features/workout_plan/data/mappers/workout_plan_mapper.dart';
import 'package:forge/features/workout_plan/domain/entities/workout_plan.dart';
import 'package:forge/features/workout_plan/domain/entities/workout_plan_detail.dart';
import 'package:forge/features/workout_plan/domain/repositories/workout_plan_repository.dart';
import 'package:fpdart/fpdart.dart';

class WorkoutPlanRepositoryImpl implements WorkoutPlanRepository {
  const WorkoutPlanRepositoryImpl({required this.dataSource});

  final WorkoutPlanLocalDataSource dataSource;

  @override
  Future<Either<AppException, List<WorkoutPlan>>> getAllPlans() async {
    try {
      final models = [...await dataSource.getAllPlans()]
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return Right(models.map(WorkoutPlanMapper.fromRecord).toList());
    } catch (e) {
      return Left(
        CacheException(
          message: "Couldn't load your workout plans",
          originalException: e,
        ),
      );
    }
  }

  @override
  Future<Either<AppException, WorkoutPlanDetail>> getPlanById(
    String planId,
  ) async {
    try {
      final model = await dataSource.getPlanById(planId);
      if (model == null) {
        return Left(CacheException(message: 'Workout plan not found'));
      }
      return Right(WorkoutPlanMapper.toDetailFromRecord(model));
    } catch (e) {
      return Left(
        CacheException(
          message: "Couldn't load the workout plan",
          originalException: e,
        ),
      );
    }
  }

  @override
  Future<Either<AppException, WorkoutPlanDetail>> savePlan(
    WorkoutPlanDetail plan,
  ) async {
    try {
      final model = WorkoutPlanMapper.toRecord(plan);
      await dataSource.savePlan(model);
      return Right(plan);
    } catch (e) {
      return Left(
        CacheException(
          message: "Couldn't save the workout plan",
          originalException: e,
        ),
      );
    }
  }

  @override
  Future<Either<AppException, void>> deletePlan(String planId) async {
    try {
      // The schedule rows of the plan are removed by the database cascade.
      await dataSource.deletePlan(planId);
      return const Right(null);
    } catch (e) {
      return Left(
        CacheException(
          message: "Couldn't delete the plan",
          originalException: e,
        ),
      );
    }
  }
}
