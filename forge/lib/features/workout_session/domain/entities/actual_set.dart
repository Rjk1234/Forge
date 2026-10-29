import 'package:equatable/equatable.dart';

/// Actual performance recorded for one set during a completed workout.
/// Fields are type-specific per [ExerciseType]:
///   weighted  → repetitions + weight
///   timeBased → durationSec
///   bodyweight → repetitions only
class ActualSet extends Equatable {
  const ActualSet({
    this.repetitions,
    this.weight,
    this.durationSec,
    this.skipped = false,
  });

  final int? repetitions;
  final double? weight;
  final int? durationSec;

  /// True if the user tapped Skip for this set rather than logging values.
  final bool skipped;

  @override
  List<Object?> get props => [repetitions, weight, durationSec, skipped];
}
