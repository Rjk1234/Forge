import 'package:equatable/equatable.dart';
import 'package:forge/core/enums/exercise_type.dart';

/// All-time best for one exercise.
///
/// Exactly one of [bestWeight], [bestDurationSec] and [bestReps] is set,
/// chosen by [type].
class PersonalBestRecord extends Equatable {
  const PersonalBestRecord({
    required this.exerciseName,
    required this.type,
    required this.bestDate,
    this.bestWeight,
    this.bestDurationSec,
    this.bestReps,
  });

  final String exerciseName;
  final ExerciseType type;

  /// Completion date of the session that produced the best.
  final DateTime bestDate;

  final double? bestWeight;
  final int? bestDurationSec;
  final int? bestReps;

  @override
  List<Object?> get props => [
    exerciseName,
    type,
    bestDate,
    bestWeight,
    bestDurationSec,
    bestReps,
  ];
}
