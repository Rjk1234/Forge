import 'package:equatable/equatable.dart';

/// Headline numbers of one exercise in one session, by exercise category.
///
/// Durations are in seconds. Used both for absolute values and for deltas
/// (latest minus previous), where negative values are regressions.
sealed class ExerciseMetrics extends Equatable {
  const ExerciseMetrics();
}

class WeightedMetrics extends ExerciseMetrics {
  const WeightedMetrics({
    required this.topWeight,
    required this.bestReps,
    required this.totalReps,
    required this.volume,
  });

  final double topWeight;
  final int bestReps;
  final int totalReps;
  final double volume;

  @override
  List<Object?> get props => [topWeight, bestReps, totalReps, volume];
}

class TimedMetrics extends ExerciseMetrics {
  const TimedMetrics({
    required this.bestDuration,
    required this.totalTime,
    required this.setCount,
  });

  final int bestDuration;
  final int totalTime;
  final int setCount;

  @override
  List<Object?> get props => [bestDuration, totalTime, setCount];
}

class BodyweightMetrics extends ExerciseMetrics {
  const BodyweightMetrics({
    required this.totalSets,
    required this.bestReps,
    required this.totalReps,
  });

  final int totalSets;
  final int bestReps;
  final int totalReps;

  @override
  List<Object?> get props => [totalSets, bestReps, totalReps];
}
