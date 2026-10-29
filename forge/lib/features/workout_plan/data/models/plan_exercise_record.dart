import 'package:forge/core/enums/exercise_type.dart';

/// A single exercise entry inside a [WorkoutPlanRecord]. Fields are type-specific:
/// weighted → targetRepetitions + targetWeight; timeBased → targetDurationSec
/// (seconds, shown mm:ss); bodyweight → targetRepetitions only.
class PlanExerciseRecord {
  final String exerciseId;

  /// Snapshot of the exercise name at plan-creation time (for display).
  final String exerciseName;

  final ExerciseType type;

  final int targetSets;

  /// weighted + bodyweight only
  final int? targetRepetitions;

  /// weighted only; strictly positive
  final double? targetWeight;

  /// timeBased only; stored in seconds
  final int? targetDurationSec;

  /// Rest between sets, in seconds
  final int restPeriodSec;

  const PlanExerciseRecord({
    required this.exerciseId,
    required this.exerciseName,
    required this.type,
    required this.targetSets,
    this.targetRepetitions,
    this.targetWeight,
    this.targetDurationSec,
    required this.restPeriodSec,
  });
}
