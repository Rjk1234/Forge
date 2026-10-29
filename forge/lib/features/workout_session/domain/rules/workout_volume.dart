import 'package:forge/core/enums/exercise_type.dart';
import 'package:forge/features/workout_session/domain/entities/session_exercise.dart';
import 'package:forge/features/workout_session/domain/entities/workout_session.dart';
import 'package:forge/features/workout_session/domain/rules/logged_set_rules.dart';

/// Rounds [value] to one decimal. Weights carry at most one decimal, so this
/// only removes floating-point noise.
double roundToOneDecimal(double value) => (value * 10).round() / 10;

/// Training volume of [exercise]: the sum of weight x reps over its valid
/// sets. Only weighted exercises carry volume; the rest contribute zero.
double exerciseVolume(SessionExercise exercise) {
  if (exercise.type != ExerciseType.weighted) return 0;
  var volume = 0.0;
  for (final set in validLoggedSets(exercise)) {
    volume += set.weight! * set.repetitions!;
  }
  return roundToOneDecimal(volume);
}

/// Total volume of [sessions], the single figure Stats and Progress share.
double totalVolume(Iterable<WorkoutSession> sessions) {
  var volume = 0.0;
  for (final session in sessions) {
    for (final exercise in session.sessionExercises) {
      volume += exerciseVolume(exercise);
    }
  }
  return roundToOneDecimal(volume);
}
