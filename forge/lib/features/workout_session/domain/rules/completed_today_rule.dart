import 'package:forge/features/workout_session/domain/entities/workout_session.dart';
import 'package:forge/features/workout_session/domain/rules/logged_set_rules.dart';

/// Whether [planId] already has a completed workout that started on [day].
///
/// The day is the session's `startedAt` date, the same key History orders by,
/// so a workout begun before midnight counts for the day it began. Cancelled
/// workouts are never stored and sessions without a valid set do not count.
bool hasCompletedWorkoutOn({
  required Iterable<WorkoutSession> sessions,
  required String planId,
  required DateTime day,
}) => sessions.any(
  (session) =>
      session.planId == planId &&
      isCompletedSession(session) &&
      _isSameDay(session.startedAt, day),
);

bool _isSameDay(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;
