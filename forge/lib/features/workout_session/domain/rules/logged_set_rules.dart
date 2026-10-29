import 'package:forge/core/enums/exercise_type.dart';
import 'package:forge/core/validation/workout_value_rules.dart';
import 'package:forge/features/workout_session/domain/entities/actual_set.dart';
import 'package:forge/features/workout_session/domain/entities/session_exercise.dart';
import 'package:forge/features/workout_session/domain/entities/workout_session.dart';

/// The one definition of a "valid, completed" set and workout.
///
/// A set counts only when it was not skipped **and** carries the values its
/// exercise type needs (weighted: reps + weight, bodyweight: reps,
/// time-based: duration). Statistics, progress and personal bests all rely on
/// this so an incomplete entry can never leak into a number.
bool isValidLoggedSet(ActualSet set, ExerciseType type) {
  if (set.skipped) return false;
  return switch (type) {
    ExerciseType.weighted =>
      WorkoutValueRules.isValidRepetitions(set.repetitions) &&
          WorkoutValueRules.isValidWeight(set.weight),
    ExerciseType.bodyweight => WorkoutValueRules.isValidRepetitions(
      set.repetitions,
    ),
    ExerciseType.timeBased => WorkoutValueRules.isValidDurationSec(
      set.durationSec,
    ),
  };
}

/// The valid, completed sets of [exercise].
List<ActualSet> validLoggedSets(SessionExercise exercise) => exercise.actualSets
    .where((set) => isValidLoggedSet(set, exercise.type))
    .toList(growable: false);

/// A session counts as a completed workout when at least one set is valid.
bool isCompletedSession(WorkoutSession session) => session.sessionExercises.any(
  (exercise) => validLoggedSets(exercise).isNotEmpty,
);
