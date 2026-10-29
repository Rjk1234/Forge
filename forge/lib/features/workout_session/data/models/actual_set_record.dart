/// Actual performance recorded for one set during a completed workout. Fields are type-specific:
/// weighted → repetitions + weight; timeBased → durationSec; bodyweight → repetitions only.
class ActualSetRecord {
  /// weighted + bodyweight only
  final int? repetitions;

  /// weighted only; strictly positive
  final double? weight;

  /// timeBased only; stored in seconds
  final int? durationSec;

  /// True if the user skipped this set during the active workout.
  final bool skipped;

  const ActualSetRecord({
    this.repetitions,
    this.weight,
    this.durationSec,
    this.skipped = false,
  });
}
