import 'package:equatable/equatable.dart';
import 'package:forge/features/workout_session/domain/entities/session_exercise.dart';

/// Immutable record of a completed workout session.
///
/// Every record in this entity is, by definition, a completed session.
/// Cancelled sessions and zero-set Finishes are never persisted — the
/// completion criterion is enforced at the repository boundary.
///
/// All plan and exercise data is copied at finish time so subsequent plan
/// edits or deletions cannot alter historical records.
class WorkoutSession extends Equatable {
  const WorkoutSession({
    required this.sessionId,
    required this.planId,
    required this.planName,
    required this.completedAt,
    required this.startedAt,
    required this.sessionDurationSec,
    required this.sessionExercises,
  });

  final String sessionId;

  /// Retained for history filtering — plan content is never re-read from here.
  final String planId;

  /// Snapshot of the plan name at session-completion time.
  final String planName;

  final DateTime completedAt;

  /// Instant the user entered SCR-16. Used to compute [sessionDurationSec].
  /// `sessionDurationSec = completedAt.difference(startedAt).inSeconds`
  final DateTime startedAt;

  /// Total session duration in seconds.
  final int sessionDurationSec;

  final List<SessionExercise> sessionExercises;

  @override
  List<Object?> get props => [
    sessionId,
    planId,
    planName,
    completedAt,
    startedAt,
    sessionDurationSec,
    sessionExercises,
  ];
}
