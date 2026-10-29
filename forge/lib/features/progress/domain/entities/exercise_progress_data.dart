import 'package:equatable/equatable.dart';
import 'package:forge/core/enums/exercise_type.dart';
import 'package:forge/features/progress/domain/entities/exercise_metrics.dart';

/// One session on the progress chart.
class ProgressDataPoint extends Equatable {
  const ProgressDataPoint({
    required this.sessionIndex,
    required this.metricValue,
    required this.date,
    required this.isLatest,
  });

  /// 1-based position within the chart window (x-axis order).
  final int sessionIndex;

  /// Best weight (weighted), best duration in seconds (time-based) or best
  /// reps (bodyweight) of the session.
  final double metricValue;

  final DateTime date;
  final bool isLatest;

  @override
  List<Object?> get props => [sessionIndex, metricValue, date, isLatest];
}

/// Everything the Progress screen shows for one exercise.
class ExerciseProgressData extends Equatable {
  const ExerciseProgressData({
    required this.exerciseName,
    required this.type,
    required this.totalValidSessions,
    required this.sessionDataPoints,
    required this.latestMetrics,
    required this.latestWorkoutDurationSec,
    this.deltaMetrics,
    this.workoutDurationDeltaSec,
  });

  final String exerciseName;
  final ExerciseType type;

  /// Sessions with at least one non-skipped set of this exercise.
  final int totalValidSessions;

  /// Oldest first, capped at the most recent sessions.
  final List<ProgressDataPoint> sessionDataPoints;
  final ExerciseMetrics latestMetrics;

  /// Latest minus previous session; null with fewer than two valid sessions.
  final ExerciseMetrics? deltaMetrics;

  /// Whole-workout duration of the latest session containing the exercise.
  final int latestWorkoutDurationSec;

  /// Latest minus previous workout duration; null like [deltaMetrics].
  final int? workoutDurationDeltaSec;

  @override
  List<Object?> get props => [
    exerciseName,
    type,
    totalValidSessions,
    sessionDataPoints,
    latestMetrics,
    deltaMetrics,
    latestWorkoutDurationSec,
    workoutDurationDeltaSec,
  ];
}
