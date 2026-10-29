import 'package:forge/core/exceptions/app_exception.dart';
import 'package:forge/features/workout_session/domain/entities/workout_session.dart';
import 'package:forge/features/workout_session/domain/repositories/workout_session_repository.dart';
import 'package:fpdart/fpdart.dart';

/// Reads one stored session; a missing record is treated as a read failure.
class GetWorkoutHistoryDetailUseCase {
  const GetWorkoutHistoryDetailUseCase(this._repository);

  final WorkoutSessionRepository _repository;

  Future<Either<AppException, WorkoutSession>> call(String sessionId) async {
    final result = await _repository.getSessionById(sessionId);
    return result.flatMap(
      (session) => session == null
          ? Left(
              CacheException(message: 'Workout session $sessionId not found'),
            )
          : Right(session),
    );
  }
}
