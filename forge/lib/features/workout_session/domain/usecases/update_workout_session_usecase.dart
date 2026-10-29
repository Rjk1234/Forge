import 'package:forge/core/exceptions/app_exception.dart';
import 'package:forge/features/workout_session/domain/entities/workout_session.dart';
import 'package:forge/features/workout_session/domain/repositories/workout_session_repository.dart';
import 'package:forge/features/workout_session/domain/usecases/save_workout_session_usecase.dart';
import 'package:fpdart/fpdart.dart';

/// Replaces the exercises of an existing logged workout.
///
/// Identity and timing (`sessionId`, plan, start/finish, duration) always come
/// from the stored session; only the exercise sets of [edited] are applied.
/// Validation and the catalogue check are those of [SaveWorkoutSessionUseCase].
class UpdateWorkoutSessionUseCase {
  const UpdateWorkoutSessionUseCase({
    required this._repository,
    required this._saveSession,
  });

  final WorkoutSessionRepository _repository;
  final SaveWorkoutSessionUseCase _saveSession;

  Future<Either<AppException, void>> call(WorkoutSession edited) async {
    final stored = await _repository.getSessionById(edited.sessionId);
    return stored.fold<Future<Either<AppException, void>>>(
      (failure) async => Left(failure),
      (original) {
        if (original == null) {
          return Future.value(
            Left(
              CacheException(
                message: 'Workout session ${edited.sessionId} not found',
              ),
            ),
          );
        }
        return _saveSession(_withOriginalIdentity(original, edited));
      },
    );
  }

  WorkoutSession _withOriginalIdentity(
    WorkoutSession original,
    WorkoutSession edited,
  ) {
    return WorkoutSession(
      sessionId: original.sessionId,
      planId: original.planId,
      planName: original.planName,
      completedAt: original.completedAt,
      startedAt: original.startedAt,
      sessionDurationSec: original.sessionDurationSec,
      sessionExercises: edited.sessionExercises,
    );
  }
}
