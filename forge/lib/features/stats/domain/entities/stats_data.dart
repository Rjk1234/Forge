import 'package:equatable/equatable.dart';

/// Aggregate totals across every valid completed workout.
class StatsData extends Equatable {
  const StatsData({
    required this.totalWorkoutsCompleted,
    required this.totalVolumeKg,
    required this.totalDurationSec,
    required this.avgDurationSec,
  });

  final int totalWorkoutsCompleted;
  final double totalVolumeKg;
  final int totalDurationSec;

  /// Null when there are no valid workouts (an average is undefined).
  final int? avgDurationSec;

  @override
  List<Object?> get props => [
    totalWorkoutsCompleted,
    totalVolumeKg,
    totalDurationSec,
    avgDurationSec,
  ];
}
