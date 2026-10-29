import 'package:forge/core/enums/exercise_type.dart';
import 'package:forge/features/home/domain/entities/planned_exercise.dart';
import 'package:forge/features/workout_session/domain/rules/workout_volume.dart';

/// Assumed time for one repetition-based set; timed sets use their target.
const int assumedSetSeconds = 45;

/// Rough length of the workout: every set plus its rest, rounded up.
int estimatedWorkoutMinutes(List<PlannedExercise> exercises) {
  var seconds = 0;
  for (final exercise in exercises) {
    final work = exercise.durationSec ?? assumedSetSeconds;
    seconds += exercise.sets * (work + exercise.restSec);
  }
  return (seconds / 60).ceil();
}

/// Sum of sets x reps x weight over the weighted exercises.
double plannedVolumeKg(List<PlannedExercise> exercises) {
  var volume = 0.0;
  for (final exercise in exercises) {
    if (exercise.type != ExerciseType.weighted) continue;
    volume +=
        exercise.sets * (exercise.repetitions ?? 0) * (exercise.weightKg ?? 0);
  }
  return roundToOneDecimal(volume);
}

int plannedSetCount(List<PlannedExercise> exercises) =>
    exercises.fold(0, (total, exercise) => total + exercise.sets);
