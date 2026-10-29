import 'package:forge/features/workout_session/domain/entities/workout_session.dart';

/// Oldest-first order used everywhere sessions are dated or compared:
/// `startedAt`, then `completedAt`, then `sessionId` so ties are stable.
int compareSessionsOldestFirst(WorkoutSession a, WorkoutSession b) {
  final byStart = a.startedAt.compareTo(b.startedAt);
  if (byStart != 0) return byStart;
  final byCompletion = a.completedAt.compareTo(b.completedAt);
  if (byCompletion != 0) return byCompletion;
  return a.sessionId.compareTo(b.sessionId);
}

/// Exact reverse of [compareSessionsOldestFirst].
int compareSessionsNewestFirst(WorkoutSession a, WorkoutSession b) =>
    compareSessionsOldestFirst(b, a);
