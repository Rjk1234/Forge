import 'package:forge/features/workout_session/data/models/actual_set_record.dart';
import 'package:forge/features/workout_session/data/models/session_exercise_record.dart';
import 'package:forge/features/workout_session/data/models/workout_session_record.dart';
import 'package:forge/features/workout_session/domain/entities/actual_set.dart';
import 'package:forge/features/workout_session/domain/entities/session_exercise.dart';
import 'package:forge/features/workout_session/domain/entities/workout_session.dart';

class WorkoutSessionMapper {
  const WorkoutSessionMapper._();

  static WorkoutSession toDomain(WorkoutSessionRecord model) => WorkoutSession(
    sessionId: model.sessionId,
    planId: model.planId,
    planName: model.planName,
    completedAt: model.completedAt,
    startedAt: model.startedAt ?? model.completedAt,
    sessionDurationSec: model.sessionDurationSec,
    sessionExercises: model.sessionExercises
        .map(_sessionExerciseToDomain)
        .toList(growable: false),
  );

  static SessionExercise _sessionExerciseToDomain(
    SessionExerciseRecord model,
  ) => SessionExercise(
    exerciseId: model.exerciseId,
    exerciseName: model.exerciseName,
    type: model.type,
    actualSets: model.actualSets
        .map(_actualSetToDomain)
        .toList(growable: false),
  );

  static ActualSet _actualSetToDomain(ActualSetRecord model) => ActualSet(
    repetitions: model.repetitions,
    weight: model.weight,
    durationSec: model.durationSec,
    skipped: model.skipped,
  );

  static WorkoutSessionRecord toRecord(WorkoutSession session) =>
      WorkoutSessionRecord(
        sessionId: session.sessionId,
        planId: session.planId,
        planName: session.planName,
        completedAt: session.completedAt,
        startedAt: session.startedAt,
        sessionDurationSec: session.sessionDurationSec,
        sessionExercises: session.sessionExercises
            .map(_sessionExerciseToRecord)
            .toList(growable: false),
      );

  static SessionExerciseRecord _sessionExerciseToRecord(
    SessionExercise exercise,
  ) => SessionExerciseRecord(
    exerciseId: exercise.exerciseId,
    exerciseName: exercise.exerciseName,
    type: exercise.type,
    actualSets: exercise.actualSets
        .map(_actualSetToRecord)
        .toList(growable: false),
  );

  static ActualSetRecord _actualSetToRecord(ActualSet set) => ActualSetRecord(
    repetitions: set.repetitions,
    weight: set.weight,
    durationSec: set.durationSec,
    skipped: set.skipped,
  );
}
