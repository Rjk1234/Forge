import 'dart:math' as math;

import 'package:forge/core/enums/exercise_type.dart';
import 'package:forge/features/progress/domain/entities/exercise_metrics.dart';
import 'package:forge/features/workout_session/domain/entities/session_exercise.dart';
import 'package:forge/features/workout_session/domain/rules/logged_set_rules.dart';
import 'package:forge/features/workout_session/domain/rules/workout_volume.dart';

/// Stat-tile numbers for [exercise], by its category.
///
/// Only valid sets count; the volume comes from the shared volume rule.
ExerciseMetrics metricsFor(SessionExercise exercise) {
  final sets = validLoggedSets(exercise);
  return switch (exercise.type) {
    ExerciseType.weighted => WeightedMetrics(
      topWeight: _maxOf(sets.map((set) => set.weight ?? 0)).toDouble(),
      bestReps: _maxOf(sets.map((set) => set.repetitions ?? 0)).toInt(),
      totalReps: sets.fold<int>(0, (t, set) => t + (set.repetitions ?? 0)),
      volume: exerciseVolume(exercise),
    ),
    ExerciseType.timeBased => TimedMetrics(
      bestDuration: _maxOf(sets.map((set) => set.durationSec ?? 0)).toInt(),
      totalTime: sets.fold<int>(0, (t, set) => t + (set.durationSec ?? 0)),
      setCount: sets.length,
    ),
    ExerciseType.bodyweight => BodyweightMetrics(
      totalSets: sets.length,
      bestReps: _maxOf(sets.map((set) => set.repetitions ?? 0)).toInt(),
      totalReps: sets.fold<int>(0, (t, set) => t + (set.repetitions ?? 0)),
    ),
  };
}

/// The single number plotted per session on the chart.
double chartValueFor(SessionExercise exercise) =>
    switch (metricsFor(exercise)) {
      WeightedMetrics(:final topWeight) => topWeight,
      TimedMetrics(:final bestDuration) => bestDuration.toDouble(),
      BodyweightMetrics(:final bestReps) => bestReps.toDouble(),
    };

/// [latest] minus [previous]; both must be the same category.
ExerciseMetrics? subtractMetrics(
  ExerciseMetrics latest,
  ExerciseMetrics previous,
) {
  return switch ((latest, previous)) {
    (final WeightedMetrics a, final WeightedMetrics b) => WeightedMetrics(
      topWeight: roundToOneDecimal(a.topWeight - b.topWeight),
      bestReps: a.bestReps - b.bestReps,
      totalReps: a.totalReps - b.totalReps,
      volume: roundToOneDecimal(a.volume - b.volume),
    ),
    (final TimedMetrics a, final TimedMetrics b) => TimedMetrics(
      bestDuration: a.bestDuration - b.bestDuration,
      totalTime: a.totalTime - b.totalTime,
      setCount: a.setCount - b.setCount,
    ),
    (final BodyweightMetrics a, final BodyweightMetrics b) => BodyweightMetrics(
      totalSets: a.totalSets - b.totalSets,
      bestReps: a.bestReps - b.bestReps,
      totalReps: a.totalReps - b.totalReps,
    ),
    _ => null,
  };
}

num _maxOf(Iterable<num> values) =>
    values.fold<num>(0, (best, value) => math.max(best, value));
