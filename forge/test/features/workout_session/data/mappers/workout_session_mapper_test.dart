import 'package:flutter_test/flutter_test.dart';
import 'package:forge/core/enums/exercise_type.dart';
import 'package:forge/features/workout_session/data/mappers/workout_session_mapper.dart';
import 'package:forge/features/workout_session/data/models/actual_set_record.dart';
import 'package:forge/features/workout_session/data/models/session_exercise_record.dart';
import 'package:forge/features/workout_session/data/models/workout_session_record.dart';
import 'package:forge/features/workout_session/domain/entities/actual_set.dart';
import 'package:forge/features/workout_session/domain/entities/session_exercise.dart';
import 'package:forge/features/workout_session/domain/entities/workout_session.dart';

void main() {
  final completedAt = DateTime(2026, 3, 1, 10, 0);

  final sessionRecord = WorkoutSessionRecord(
    sessionId: 'sess-1',
    planId: 'plan-1',
    planName: 'Strength A',
    completedAt: completedAt,
    sessionDurationSec: 3600,
    sessionExercises: [
      SessionExerciseRecord(
        exerciseId: 'ex-1',
        exerciseName: 'Squat',
        type: ExerciseType.weighted,
        actualSets: [
          ActualSetRecord(repetitions: 8, weight: 100.0),
          ActualSetRecord(repetitions: 6, weight: 110.0),
        ],
      ),
      SessionExerciseRecord(
        exerciseId: 'ex-2',
        exerciseName: 'Plank',
        type: ExerciseType.timeBased,
        actualSets: [ActualSetRecord(durationSec: 60)],
      ),
    ],
  );

  final domainSession = WorkoutSession(
    sessionId: 'sess-1',
    planId: 'plan-1',
    planName: 'Strength A',
    completedAt: completedAt,
    startedAt: completedAt,
    sessionDurationSec: 3600,
    sessionExercises: [
      const SessionExercise(
        exerciseId: 'ex-1',
        exerciseName: 'Squat',
        type: ExerciseType.weighted,
        actualSets: [
          ActualSet(repetitions: 8, weight: 100.0),
          ActualSet(repetitions: 6, weight: 110.0),
        ],
      ),
      const SessionExercise(
        exerciseId: 'ex-2',
        exerciseName: 'Plank',
        type: ExerciseType.timeBased,
        actualSets: [ActualSet(durationSec: 60)],
      ),
    ],
  );

  group('WorkoutSessionMapper.toDomain', () {
    test('maps all top-level fields correctly', () {
      final result = WorkoutSessionMapper.toDomain(sessionRecord);

      expect(result.sessionId, 'sess-1');
      expect(result.planId, 'plan-1');
      expect(result.planName, 'Strength A');
      expect(result.completedAt, completedAt);
      expect(result.sessionDurationSec, 3600);
    });

    test('maps nested exercises and sets correctly', () {
      final result = WorkoutSessionMapper.toDomain(sessionRecord);

      expect(result.sessionExercises.length, 2);
      final squat = result.sessionExercises.first;
      expect(squat.exerciseId, 'ex-1');
      expect(squat.exerciseName, 'Squat');
      expect(squat.type, ExerciseType.weighted);
      expect(squat.actualSets.length, 2);
      expect(squat.actualSets.first.repetitions, 8);
      expect(squat.actualSets.first.weight, 100.0);
    });

    test('maps timeBased exercise with durationSec correctly', () {
      final result = WorkoutSessionMapper.toDomain(sessionRecord);
      final plank = result.sessionExercises[1];
      expect(plank.type, ExerciseType.timeBased);
      expect(plank.actualSets.first.durationSec, 60);
    });
  });

  group('WorkoutSessionMapper.toRecord', () {
    test('maps all top-level fields correctly', () {
      final result = WorkoutSessionMapper.toRecord(domainSession);

      expect(result.sessionId, 'sess-1');
      expect(result.planId, 'plan-1');
      expect(result.planName, 'Strength A');
      expect(result.completedAt, completedAt);
      expect(result.sessionDurationSec, 3600);
    });

    test('maps nested exercises and sets correctly', () {
      final result = WorkoutSessionMapper.toRecord(domainSession);

      expect(result.sessionExercises.length, 2);
      final squat = result.sessionExercises.first;
      expect(squat.exerciseId, 'ex-1');
      expect(squat.exerciseName, 'Squat');
      expect(squat.actualSets.first.repetitions, 8);
      expect(squat.actualSets.first.weight, 100.0);
    });
  });

  group('WorkoutSessionMapper — round-trip', () {
    test('domain → record → domain preserves all values', () {
      final record = WorkoutSessionMapper.toRecord(domainSession);
      final roundTripped = WorkoutSessionMapper.toDomain(record);

      expect(roundTripped.sessionId, domainSession.sessionId);
      expect(roundTripped.planName, domainSession.planName);
      expect(
        roundTripped.sessionExercises.first.exerciseName,
        domainSession.sessionExercises.first.exerciseName,
      );
      expect(
        roundTripped.sessionExercises.first.actualSets.first.weight,
        domainSession.sessionExercises.first.actualSets.first.weight,
      );
    });

    test('record → domain → record preserves all values', () {
      final domain = WorkoutSessionMapper.toDomain(sessionRecord);
      final roundTripped = WorkoutSessionMapper.toRecord(domain);

      expect(roundTripped.sessionId, sessionRecord.sessionId);
      expect(roundTripped.planName, sessionRecord.planName);
      expect(
        roundTripped.sessionExercises.first.actualSets.first.repetitions,
        sessionRecord.sessionExercises.first.actualSets.first.repetitions,
      );
    });
  });
}
