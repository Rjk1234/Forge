import 'package:forge/core/exceptions/app_exception.dart';
import 'package:forge/features/exercise/domain/entities/exercise.dart';
import 'package:forge/features/exercise/domain/repositories/exercise_repository.dart';
import 'package:forge/features/workout_session/domain/entities/workout_session.dart';
import 'package:forge/features/workout_session/domain/repositories/workout_session_repository.dart';
import 'package:forge/features/workout_session/domain/validation/session_validator.dart';
import 'package:forge/features/workout_session/domain/validation/session_violation.dart';
import 'package:fpdart/fpdart.dart';

/// The only way a workout log is stored: validated, with every exercise
/// reference checked against the catalogue, then written by the repository.
class SaveWorkoutSessionUseCase {
  const SaveWorkoutSessionUseCase({
    required this._repository,
    required this._exerciseRepository,
    this._validator = const SessionValidator(),
  });

  final WorkoutSessionRepository _repository;
  final ExerciseRepository _exerciseRepository;
  final SessionValidator _validator;

  Future<Either<AppException, void>> call(WorkoutSession session) async {
    final violations = _validator.validate(session);
    if (violations.isNotEmpty) return Left(_toException(violations));

    final catalogue = await _exerciseRepository.getExercises();
    return catalogue.fold<Future<Either<AppException, void>>>(
      (failure) async => Left(failure),
      (exercises) => _saveChecked(session, exercises),
    );
  }

  Future<Either<AppException, void>> _saveChecked(
    WorkoutSession session,
    List<Exercise> catalogue,
  ) {
    final knownIds = {for (final exercise in catalogue) exercise.id};
    final unknown = <SessionViolation>[
      for (var i = 0; i < session.sessionExercises.length; i++)
        if (!knownIds.contains(session.sessionExercises[i].exerciseId))
          SessionViolation(
            SessionViolationType.unknownExercise,
            exerciseIndex: i,
          ),
    ];
    if (unknown.isNotEmpty) return Future.value(Left(_toException(unknown)));
    return _repository.saveSession(session);
  }

  ValidationException _toException(List<SessionViolation> violations) {
    return ValidationException(
      message: 'Workout log is invalid: ${violations.join(', ')}',
      code: violations.first.type.name,
    );
  }
}
