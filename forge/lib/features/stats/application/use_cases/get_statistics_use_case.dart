import 'dart:math' as math;

import 'package:forge/core/exceptions/app_exception.dart';
import 'package:forge/features/stats/domain/entities/exercise_stat_row.dart';
import 'package:forge/features/stats/domain/entities/stats_data.dart';
import 'package:forge/features/workout_session/domain/entities/workout_session.dart';
import 'package:forge/features/workout_session/domain/repositories/workout_session_repository.dart';
import 'package:forge/features/workout_session/domain/rules/exercise_history.dart';
import 'package:forge/features/workout_session/domain/rules/logged_set_rules.dart';
import 'package:forge/features/workout_session/domain/rules/session_ordering.dart';
import 'package:forge/features/workout_session/domain/rules/workout_volume.dart';
import 'package:fpdart/fpdart.dart';

typedef StatsSummary = ({StatsData stats, List<ExerciseStatRow> exercises});

/// Computes the statistics dashboard from every stored session (read-only).
class GetStatisticsUseCase {
  const GetStatisticsUseCase(this._repository);

  final WorkoutSessionRepository _repository;

  Future<Either<AppException, StatsSummary>> call() async {
    final result = await _repository.getAllSessions();
    return result.map(_summarise);
  }

  StatsSummary _summarise(List<WorkoutSession> sessions) {
    final valid = sessions.where(isCompletedSession).toList()
      ..sort(compareSessionsOldestFirst);
    final totalDurationSec = valid.fold<int>(
      0,
      (total, session) => total + session.sessionDurationSec,
    );

    return (
      stats: StatsData(
        totalWorkoutsCompleted: valid.length,
        totalVolumeKg: totalVolume(valid),
        totalDurationSec: totalDurationSec,
        avgDurationSec: valid.isEmpty ? null : totalDurationSec ~/ valid.length,
      ),
      exercises: _exerciseRows(valid),
    );
  }

  List<ExerciseStatRow> _exerciseRows(List<WorkoutSession> sessions) {
    return [
      for (final entries in exerciseHistoryById(sessions).values)
        _rowFor(entries),
    ]..sort((a, b) {
      final bySessions = b.sessionCount.compareTo(a.sessionCount);
      return bySessions != 0
          ? bySessions
          : a.exerciseName.compareTo(b.exerciseName);
    });
  }

  /// [entries] are oldest first, so the last one names the exercise.
  ExerciseStatRow _rowFor(List<ExerciseSessionEntry> entries) {
    final sets = [for (final entry in entries) ...entry.exercise.actualSets];
    final latest = entries.last.exercise;
    return ExerciseStatRow(
      exerciseName: latest.exerciseName,
      type: latest.type,
      sessionCount: entries.length,
      bestWeight: _best(sets.map((set) => set.weight ?? 0)).toDouble(),
      bestReps: _best(sets.map((set) => set.repetitions ?? 0)).toInt(),
      bestDurationSec: _best(sets.map((set) => set.durationSec ?? 0)).toInt(),
    );
  }

  num _best(Iterable<num> values) =>
      values.fold<num>(0, (best, value) => math.max(best, value));
}
