import 'package:forge/features/workout_session/domain/entities/session_exercise.dart';
import 'package:forge/features/workout_session/domain/entities/workout_session.dart';
import 'package:forge/features/workout_session/domain/rules/logged_set_rules.dart';
import 'package:forge/features/workout_session/domain/rules/session_ordering.dart';

/// One exercise's contribution to one session: every occurrence of the
/// exercise in that session merged, holding only its valid sets.
class ExerciseSessionEntry {
  const ExerciseSessionEntry({required this.session, required this.exercise});

  final WorkoutSession session;
  final SessionExercise exercise;
}

/// The exercises of [session] by `exerciseId`, one entry each, with the valid
/// sets of repeated occurrences concatenated. Exercises with no valid set are
/// dropped.
List<SessionExercise> aggregateSessionExercises(WorkoutSession session) {
  final merged = <String, SessionExercise>{};
  for (final exercise in session.sessionExercises) {
    final sets = validLoggedSets(exercise);
    if (sets.isEmpty) continue;
    final existing = merged[exercise.exerciseId];
    merged[exercise.exerciseId] = SessionExercise(
      exerciseId: exercise.exerciseId,
      exerciseName: existing?.exerciseName ?? exercise.exerciseName,
      type: existing?.type ?? exercise.type,
      actualSets: [...?existing?.actualSets, ...sets],
    );
  }
  return merged.values.toList(growable: false);
}

/// Every exercise's history by `exerciseId`, each list oldest first by
/// [compareSessionsOldestFirst] with one entry per session.
Map<String, List<ExerciseSessionEntry>> exerciseHistoryById(
  Iterable<WorkoutSession> sessions,
) {
  final history = <String, List<ExerciseSessionEntry>>{};
  final ordered = sessions.where(isCompletedSession).toList()
    ..sort(compareSessionsOldestFirst);
  for (final session in ordered) {
    for (final exercise in aggregateSessionExercises(session)) {
      history
          .putIfAbsent(exercise.exerciseId, () => [])
          .add(ExerciseSessionEntry(session: session, exercise: exercise));
    }
  }
  return history;
}
