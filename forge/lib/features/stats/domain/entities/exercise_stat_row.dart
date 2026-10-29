import 'package:equatable/equatable.dart';
import 'package:forge/core/enums/exercise_type.dart';

/// One exercise in the breakdown: how often it was done and its best value.
///
/// Only the best value matching [type] is meaningful; the others are zero.
class ExerciseStatRow extends Equatable {
  const ExerciseStatRow({
    required this.exerciseName,
    required this.type,
    required this.sessionCount,
    required this.bestWeight,
    required this.bestReps,
    required this.bestDurationSec,
  });

  final String exerciseName;
  final ExerciseType type;
  final int sessionCount;
  final double bestWeight;
  final int bestReps;
  final int bestDurationSec;

  @override
  List<Object?> get props => [
    exerciseName,
    type,
    sessionCount,
    bestWeight,
    bestReps,
    bestDurationSec,
  ];
}
