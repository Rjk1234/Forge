import 'package:forge/core/exceptions/app_exception.dart';
import 'package:forge/features/workout_session/domain/entities/workout_session.dart';
import 'package:fpdart/fpdart.dart';

abstract class WorkoutSessionRepository {
  /// All completed session records, unsorted.
  Future<Either<AppException, List<WorkoutSession>>> getAllSessions();

  /// Sessions for a specific plan (for history filtering).
  Future<Either<AppException, List<WorkoutSession>>> getSessionsByPlanId(
    String planId,
  );

  /// Single session by ID, or null if not found.
  Future<Either<AppException, WorkoutSession?>> getSessionById(
    String sessionId,
  );

  /// Persist a completed session record.
  ///
  /// Enforces the completion criterion: session must have at least one exercise
  /// with at least one logged set. If the criterion is not met, returns
  /// [Left] with a [CacheException] and performs no write.
  Future<Either<AppException, void>> saveSession(WorkoutSession session);

  /// Delete a session record (e.g. data-clear flows).
  Future<Either<AppException, void>> deleteSession(String sessionId);
}
