import 'package:forge/core/enums/exercise_type.dart';
import 'package:forge/features/workout_session/domain/entities/actual_set.dart';
import 'package:forge/features/workout_session/domain/entities/session_exercise.dart';
import 'package:forge/features/workout_session/domain/entities/workout_session.dart';

/// A one-exercise session of [planId] started at [startedAt].
///
/// With [allSkipped] the only set is skipped, so it is not a completed workout.
WorkoutSession sessionOf({
  required String planId,
  required DateTime startedAt,
  String sessionId = 's1',
  bool allSkipped = false,
}) => WorkoutSession(
  sessionId: sessionId,
  planId: planId,
  planName: 'Plan $planId',
  completedAt: startedAt.add(const Duration(minutes: 45)),
  startedAt: startedAt,
  sessionDurationSec: 2700,
  sessionExercises: [
    SessionExercise(
      exerciseId: 'bench',
      exerciseName: 'Bench',
      type: ExerciseType.weighted,
      actualSets: [ActualSet(repetitions: 5, weight: 60, skipped: allSkipped)],
    ),
  ],
);
