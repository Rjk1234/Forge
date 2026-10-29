import 'package:equatable/equatable.dart';
import 'package:forge/core/enums/exercise_type.dart';

/// A single exercise entry within a [WorkoutPlanDetail].
///
/// Fields are type-specific:
///   weighted   → targetRepetitions + targetWeight
///   timeBased  → targetDurationSec
///   bodyweight → targetRepetitions only
class PlanExercise extends Equatable {
  const PlanExercise({
    required this.exerciseId,
    required this.exerciseName,
    required this.type,
    required this.targetSets,
    required this.restPeriodSec,
    this.targetRepetitions,
    this.targetWeight,
    this.targetDurationSec,
  });

  final String exerciseId;

  /// Snapshot of the exercise name at plan-creation time.
  final String exerciseName;

  final ExerciseType type;
  final int targetSets;

  /// Rest between sets in seconds (0 is valid).
  final int restPeriodSec;

  /// weighted + bodyweight only.
  final int? targetRepetitions;

  /// weighted only; strictly positive.
  final double? targetWeight;

  /// timeBased only; stored in seconds.
  final int? targetDurationSec;

  /// Same exercise target with the name refreshed from the catalogue.
  PlanExercise copyWithName(String name) => PlanExercise(
    exerciseId: exerciseId,
    exerciseName: name,
    type: type,
    targetSets: targetSets,
    restPeriodSec: restPeriodSec,
    targetRepetitions: targetRepetitions,
    targetWeight: targetWeight,
    targetDurationSec: targetDurationSec,
  );

  @override
  List<Object?> get props => [
    exerciseId,
    exerciseName,
    type,
    targetSets,
    restPeriodSec,
    targetRepetitions,
    targetWeight,
    targetDurationSec,
  ];
}
