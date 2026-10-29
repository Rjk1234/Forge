import 'session_exercise_record.dart';

/// A completed workout session keyed by [sessionId]. Every record is, by definition, a completed session (cancelled sessions are discarded before reaching persistence — SDS-COMP-7), so there is no status field. Actual performance values are copied in at finish time so plan edits cannot rewrite historical data.
class WorkoutSessionRecord {
  final String sessionId;

  /// Reference to the source plan (retained for linking, not for reading targets).
  final String planId;

  /// Snapshot of the plan name at session-completion time.
  final String planName;

  final DateTime completedAt;

  /// Total session duration in seconds.
  final int sessionDurationSec;

  final List<SessionExerciseRecord> sessionExercises;

  /// When the session began (entered the active workout screen).
  final DateTime? startedAt;

  const WorkoutSessionRecord({
    required this.sessionId,
    required this.planId,
    required this.planName,
    required this.completedAt,
    required this.sessionDurationSec,
    required this.sessionExercises,
    this.startedAt,
  });
}
