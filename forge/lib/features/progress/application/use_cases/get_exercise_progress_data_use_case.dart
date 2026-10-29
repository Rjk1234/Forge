import 'package:forge/core/exceptions/app_exception.dart';
import 'package:forge/features/progress/application/use_cases/progress_metrics.dart';
import 'package:forge/features/progress/domain/entities/exercise_progress_data.dart';
import 'package:forge/features/workout_session/domain/entities/workout_session.dart';
import 'package:forge/features/workout_session/domain/repositories/workout_session_repository.dart';
import 'package:forge/features/workout_session/domain/rules/exercise_history.dart';
import 'package:forge/features/workout_session/domain/rules/session_ordering.dart';
import 'package:fpdart/fpdart.dart';

/// Builds per-exercise progress from every stored session (read-only).
class GetExerciseProgressDataUseCase {
  const GetExerciseProgressDataUseCase({required this._repository});

  /// Most recent sessions plotted on the chart.
  static const int maxChartSessions = 12;

  /// Sessions needed before a chart and deltas make sense.
  static const int minSessionsForComparison = 2;

  final WorkoutSessionRepository _repository;

  Future<Either<AppException, List<ExerciseProgressData>>> call() async {
    final result = await _repository.getAllSessions();
    return result.map(_buildProgress);
  }

  List<ExerciseProgressData> _buildProgress(List<WorkoutSession> sessions) {
    final progress = [
      for (final entries in exerciseHistoryById(sessions).values)
        _progressFor(entries),
    ]..sort(_byChipOrder);
    return progress.map((item) => item.data).toList(growable: false);
  }

  /// [entries] are oldest first with one entry per session.
  _RankedProgress _progressFor(List<ExerciseSessionEntry> entries) {
    final latest = entries.last;
    final window = entries.length > maxChartSessions
        ? entries.sublist(entries.length - maxChartSessions)
        : entries;
    final latestMetrics = metricsFor(latest.exercise);
    final hasComparison = entries.length >= minSessionsForComparison;

    return _RankedProgress(
      latestSession: latest.session,
      data: ExerciseProgressData(
        exerciseName: latest.exercise.exerciseName,
        type: latest.exercise.type,
        totalValidSessions: entries.length,
        sessionDataPoints: [
          for (var i = 0; i < window.length; i++)
            ProgressDataPoint(
              sessionIndex: i + 1,
              metricValue: chartValueFor(window[i].exercise),
              date: window[i].session.startedAt,
              isLatest: i == window.length - 1,
            ),
        ],
        latestMetrics: latestMetrics,
        deltaMetrics: hasComparison
            ? subtractMetrics(
                latestMetrics,
                metricsFor(entries[entries.length - 2].exercise),
              )
            : null,
        latestWorkoutDurationSec: latest.session.sessionDurationSec,
        workoutDurationDeltaSec: hasComparison
            ? latest.session.sessionDurationSec -
                  entries[entries.length - 2].session.sessionDurationSec
            : null,
      ),
    );
  }

  /// Comparable exercises first, newest activity first, then alphabetical.
  int _byChipOrder(_RankedProgress a, _RankedProgress b) {
    final aComparable = a.data.totalValidSessions >= minSessionsForComparison;
    final bComparable = b.data.totalValidSessions >= minSessionsForComparison;
    if (aComparable != bComparable) return aComparable ? -1 : 1;
    final byRecency = compareSessionsNewestFirst(
      a.latestSession,
      b.latestSession,
    );
    if (byRecency != 0) return byRecency;
    return a.data.exerciseName.compareTo(b.data.exerciseName);
  }
}

class _RankedProgress {
  const _RankedProgress({required this.latestSession, required this.data});

  final WorkoutSession latestSession;
  final ExerciseProgressData data;
}
