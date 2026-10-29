import 'package:forge/core/exceptions/app_exception.dart';
import 'package:forge/features/workout_session/domain/repositories/workout_session_repository.dart';
import 'package:fpdart/fpdart.dart';

/// Removes one logged workout; every statistic is derived from the stored
/// sessions, so nothing else needs adjusting.
class DeleteWorkoutSessionUseCase {
  const DeleteWorkoutSessionUseCase(this._repository);

  final WorkoutSessionRepository _repository;

  Future<Either<AppException, void>> call(String sessionId) =>
      _repository.deleteSession(sessionId);
}
