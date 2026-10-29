import 'package:forge/core/exceptions/app_exception.dart';
import 'package:forge/features/workout_session/data/datasources/workout_session_local_data_source.dart';
import 'package:forge/features/workout_session/data/mappers/workout_session_mapper.dart';
import 'package:forge/features/workout_session/domain/entities/workout_session.dart';
import 'package:forge/features/workout_session/domain/repositories/workout_session_repository.dart';
import 'package:forge/features/workout_session/domain/rules/logged_set_rules.dart';
import 'package:fpdart/fpdart.dart';

class WorkoutSessionRepositoryImpl implements WorkoutSessionRepository {
  const WorkoutSessionRepositoryImpl({required this.dataSource});

  final WorkoutSessionLocalDataSource dataSource;

  @override
  Future<Either<AppException, List<WorkoutSession>>> getAllSessions() async {
    try {
      final models = await dataSource.getAllSessions();
      return Right(
        models.map(WorkoutSessionMapper.toDomain).toList(growable: false),
      );
    } catch (e) {
      return Left(
        CacheException(
          message: "Couldn't load workout history",
          originalException: e,
        ),
      );
    }
  }

  @override
  Future<Either<AppException, List<WorkoutSession>>> getSessionsByPlanId(
    String planId,
  ) async {
    try {
      final models = await dataSource.getSessionsByPlanId(planId);
      return Right(
        models.map(WorkoutSessionMapper.toDomain).toList(growable: false),
      );
    } catch (e) {
      return Left(
        CacheException(
          message: "Couldn't load workout history",
          originalException: e,
        ),
      );
    }
  }

  @override
  Future<Either<AppException, WorkoutSession?>> getSessionById(
    String sessionId,
  ) async {
    try {
      final model = await dataSource.getSessionById(sessionId);
      return Right(model == null ? null : WorkoutSessionMapper.toDomain(model));
    } catch (e) {
      return Left(
        CacheException(
          message: "Couldn't load the workout record",
          originalException: e,
        ),
      );
    }
  }

  @override
  Future<Either<AppException, void>> saveSession(WorkoutSession session) async {
    if (!isCompletedSession(session)) {
      return Left(
        CacheException(
          message: 'Session does not meet the completion criterion',
        ),
      );
    }
    try {
      final model = WorkoutSessionMapper.toRecord(session);
      await dataSource.saveSession(model);
      return const Right(null);
    } catch (e) {
      return Left(
        CacheException(
          message: "Couldn't save the workout record",
          originalException: e,
        ),
      );
    }
  }

  @override
  Future<Either<AppException, void>> deleteSession(String sessionId) async {
    try {
      await dataSource.deleteSession(sessionId);
      return const Right(null);
    } catch (e) {
      return Left(
        CacheException(
          message: "Couldn't delete the workout record",
          originalException: e,
        ),
      );
    }
  }
}
