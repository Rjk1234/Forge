import 'package:forge/core/enums/exercise_type.dart';
import 'package:forge/core/validation/workout_value_rules.dart';
import 'package:forge/features/workout_session/domain/entities/actual_set.dart';
import 'package:forge/features/workout_session/domain/entities/session_exercise.dart';
import 'package:forge/features/workout_session/domain/entities/workout_session.dart';
import 'package:forge/features/workout_session/domain/rules/logged_set_rules.dart';
import 'package:forge/features/workout_session/domain/validation/session_violation.dart';

/// Checks a workout log against the manager's rules before it is stored.
class SessionValidator {
  const SessionValidator();

  List<SessionViolation> validate(WorkoutSession session) {
    return [
      if (session.sessionId.trim().isEmpty)
        const SessionViolation(SessionViolationType.missingSessionId),
      if (session.planId.trim().isEmpty || session.planName.trim().isEmpty)
        const SessionViolation(SessionViolationType.missingPlanReference),
      if (!WorkoutValueRules.isValidSessionDurationSec(
        session.sessionDurationSec,
      ))
        const SessionViolation(SessionViolationType.invalidDuration),
      if (session.completedAt.isBefore(session.startedAt))
        const SessionViolation(SessionViolationType.invalidTimeRange),
      if (session.sessionExercises.isEmpty)
        const SessionViolation(SessionViolationType.noExercises),
      for (var i = 0; i < session.sessionExercises.length; i++)
        ..._validateExercise(session.sessionExercises[i], i),
      if (session.sessionExercises.isNotEmpty && !isCompletedSession(session))
        const SessionViolation(SessionViolationType.noValidLoggedSet),
    ];
  }

  List<SessionViolation> _validateExercise(
    SessionExercise exercise,
    int index,
  ) {
    SessionViolation violation(SessionViolationType type) =>
        SessionViolation(type, exerciseIndex: index);

    return [
      if (exercise.exerciseId.trim().isEmpty ||
          exercise.exerciseName.trim().isEmpty)
        violation(SessionViolationType.missingExerciseReference),
      if (exercise.actualSets.isEmpty)
        violation(SessionViolationType.exerciseWithoutSets),
      if (exercise.actualSets.any((set) => !_isWellFormed(set, exercise.type)))
        violation(SessionViolationType.invalidSet),
    ];
  }

  /// Skipped sets only have to be free of nonsense values; logged sets must
  /// carry the values their exercise type needs.
  bool _isWellFormed(ActualSet set, ExerciseType type) {
    if (isValidLoggedSet(set, type)) return true;
    if (!set.skipped) return false;
    return _isAbsentOrPositive(set.repetitions) &&
        _isAbsentOrPositive(set.weight) &&
        _isAbsentOrPositive(set.durationSec);
  }

  bool _isAbsentOrPositive(num? value) =>
      value == null || (value.isFinite && value > 0);
}
