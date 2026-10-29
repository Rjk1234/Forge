import 'package:flutter_test/flutter_test.dart';
import 'package:forge/core/enums/exercise_type.dart';
import 'package:forge/features/workout_session/data/mappers/workout_session_mapper.dart';
import 'package:forge/features/workout_session/domain/entities/actual_set.dart';
import 'package:forge/features/workout_session/domain/entities/session_exercise.dart';
import 'package:forge/features/workout_session/domain/entities/workout_session.dart';

void main() {
  group('WorkoutSessionMapper — snapshot copy (FR-006, SC-004)', () {
    test(
      'toRecord copies planName as a value string — not a live reference',
      () {
        var planName = 'Strength A';

        final session = WorkoutSession(
          sessionId: 's1',
          planId: 'p1',
          planName: planName,
          completedAt: DateTime(2026, 1, 1),
          startedAt: DateTime(2026, 1, 1),
          sessionDurationSec: 3600,
          sessionExercises: const [
            SessionExercise(
              exerciseId: 'e1',
              exerciseName: 'Squat',
              type: ExerciseType.weighted,
              actualSets: [ActualSet(repetitions: 5, weight: 100.0)],
            ),
          ],
        );

        final sessionRecord = WorkoutSessionMapper.toRecord(session);

        // Simulate plan rename by reassigning the local variable.
        // The record must not change — it captured a value copy.
        // ignore: unused_local_variable
        planName = 'Power B';

        expect(
          sessionRecord.planName,
          'Strength A',
          reason:
              'planName in the record must be a value copy captured at '
              'write time; it must not reflect subsequent mutations.',
        );
      },
    );

    test(
      'toRecord copies exerciseName as a value string — not a live reference',
      () {
        var exerciseName = 'Squat';

        final session = WorkoutSession(
          sessionId: 's1',
          planId: 'p1',
          planName: 'Plan A',
          completedAt: DateTime(2026, 1, 1),
          startedAt: DateTime(2026, 1, 1),
          sessionDurationSec: 60,
          sessionExercises: [
            SessionExercise(
              exerciseId: 'e1',
              exerciseName: exerciseName,
              type: ExerciseType.weighted,
              actualSets: const [ActualSet(repetitions: 5, weight: 100.0)],
            ),
          ],
        );

        final sessionRecord = WorkoutSessionMapper.toRecord(session);

        // Simulate exercise rename.
        // ignore: unused_local_variable
        exerciseName = 'Front Squat';

        expect(
          sessionRecord.sessionExercises.first.exerciseName,
          'Squat',
          reason:
              'exerciseName in the record must be a snapshot captured '
              'at write time; plan edits must not alter historical records.',
        );
      },
    );

    test(
      'toRecord copies actual set values — modifying domain entity after mapping has no effect',
      () {
        final originalSet = const ActualSet(repetitions: 10, weight: 80.0);

        final session = WorkoutSession(
          sessionId: 's1',
          planId: 'p1',
          planName: 'Plan A',
          completedAt: DateTime(2026, 1, 1),
          startedAt: DateTime(2026, 1, 1),
          sessionDurationSec: 60,
          sessionExercises: [
            SessionExercise(
              exerciseId: 'e1',
              exerciseName: 'Bench',
              type: ExerciseType.weighted,
              actualSets: [originalSet],
            ),
          ],
        );

        final sessionRecord = WorkoutSessionMapper.toRecord(session);

        // The record captures a copy of the values.
        expect(
          sessionRecord.sessionExercises.first.actualSets.first.repetitions,
          10,
        );
        expect(
          sessionRecord.sessionExercises.first.actualSets.first.weight,
          80.0,
        );
      },
    );
  });
}
