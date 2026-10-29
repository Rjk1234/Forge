import 'package:flutter_test/flutter_test.dart';
import 'package:forge/core/enums/exercise_type.dart';
import 'package:forge/features/workout_plan/data/mappers/workout_plan_mapper.dart';
import 'package:forge/features/workout_plan/data/models/plan_exercise_record.dart';
import 'package:forge/features/workout_plan/data/models/workout_plan_record.dart';
import 'package:forge/features/workout_plan/domain/entities/plan_exercise.dart';
import 'package:forge/features/workout_plan/domain/entities/workout_plan_detail.dart';

WorkoutPlanRecord _planRecord({
  String planId = 'plan-1',
  String name = 'Push Day',
  List<PlanExerciseRecord>? exercises,
  DateTime? createdAt,
}) => WorkoutPlanRecord(
  planId: planId,
  name: name,
  planExercises: exercises ?? [],
  createdAt: createdAt ?? DateTime(2024, 1, 1),
  updatedAt: DateTime(2024, 1, 2),
);

PlanExerciseRecord _exerciseRecord({
  String exerciseId = 'ex-1',
  String exerciseName = 'Bench Press',
  ExerciseType type = ExerciseType.weighted,
  int targetSets = 3,
  int restPeriodSec = 90,
  int? targetRepetitions = 10,
  double? targetWeight = 60.0,
  int? targetDurationSec,
}) => PlanExerciseRecord(
  exerciseId: exerciseId,
  exerciseName: exerciseName,
  type: type,
  targetSets: targetSets,
  targetRepetitions: targetRepetitions,
  targetWeight: targetWeight,
  targetDurationSec: targetDurationSec,
  restPeriodSec: restPeriodSec,
);

void main() {
  group('WorkoutPlanMapper', () {
    group('fromRecord', () {
      test('maps planId to id', () {
        final model = _planRecord(planId: 'abc');
        expect(WorkoutPlanMapper.fromRecord(model).id, 'abc');
      });

      test('maps exerciseCount from planExercises.length', () {
        final model = _planRecord(
          exercises: [_exerciseRecord(), _exerciseRecord()],
        );
        expect(WorkoutPlanMapper.fromRecord(model).exerciseCount, 2);
      });
    });

    group('toDetailFromRecord', () {
      test('maps planId to id', () {
        final model = _planRecord(planId: 'plan-x');
        expect(WorkoutPlanMapper.toDetailFromRecord(model).id, 'plan-x');
      });

      test('maps name correctly', () {
        final model = _planRecord(name: 'Leg Day');
        expect(WorkoutPlanMapper.toDetailFromRecord(model).name, 'Leg Day');
      });

      test('maps exercises list', () {
        final model = _planRecord(
          exercises: [
            _exerciseRecord(exerciseId: 'e1'),
            _exerciseRecord(exerciseId: 'e2'),
          ],
        );
        final detail = WorkoutPlanMapper.toDetailFromRecord(model);
        expect(detail.exercises.length, 2);
        expect(detail.exercises[0].exerciseId, 'e1');
        expect(detail.exercises[1].exerciseId, 'e2');
      });

      test('maps createdAt', () {
        final date = DateTime(2025, 6, 15);
        final model = _planRecord(createdAt: date);
        expect(WorkoutPlanMapper.toDetailFromRecord(model).createdAt, date);
      });
    });

    group('planExerciseFromRecord', () {
      test('maps weighted exercise fields', () {
        final record = _exerciseRecord(
          exerciseId: 'ex-w',
          type: ExerciseType.weighted,
          targetSets: 4,
          targetRepetitions: 8,
          targetWeight: 80.0,
          restPeriodSec: 120,
        );
        final exercise = WorkoutPlanMapper.planExerciseFromRecord(record);
        expect(exercise.exerciseId, 'ex-w');
        expect(exercise.type, ExerciseType.weighted);
        expect(exercise.targetSets, 4);
        expect(exercise.targetRepetitions, 8);
        expect(exercise.targetWeight, 80.0);
        expect(exercise.restPeriodSec, 120);
        expect(exercise.targetDurationSec, isNull);
      });

      test('maps timeBased exercise fields', () {
        final record = _exerciseRecord(
          type: ExerciseType.timeBased,
          targetRepetitions: null,
          targetWeight: null,
          targetDurationSec: 60,
        );
        final exercise = WorkoutPlanMapper.planExerciseFromRecord(record);
        expect(exercise.type, ExerciseType.timeBased);
        expect(exercise.targetDurationSec, 60);
        expect(exercise.targetRepetitions, isNull);
        expect(exercise.targetWeight, isNull);
      });

      test('maps bodyweight exercise fields', () {
        final record = _exerciseRecord(
          type: ExerciseType.bodyweight,
          targetRepetitions: 15,
          targetWeight: null,
          targetDurationSec: null,
        );
        final exercise = WorkoutPlanMapper.planExerciseFromRecord(record);
        expect(exercise.type, ExerciseType.bodyweight);
        expect(exercise.targetRepetitions, 15);
        expect(exercise.targetWeight, isNull);
      });

      test('rest period 0 is valid', () {
        final record = _exerciseRecord(restPeriodSec: 0);
        expect(
          WorkoutPlanMapper.planExerciseFromRecord(record).restPeriodSec,
          0,
        );
      });
    });

    group('toRecord', () {
      final createdAt = DateTime(2024, 3, 10);
      final detail = WorkoutPlanDetail(
        id: 'plan-99',
        name: 'Full Body',
        createdAt: createdAt,
        exercises: const [
          PlanExercise(
            exerciseId: 'ex-1',
            exerciseName: 'Squat',
            type: ExerciseType.weighted,
            targetSets: 3,
            restPeriodSec: 90,
            targetRepetitions: 5,
            targetWeight: 100.0,
          ),
        ],
      );

      test('maps id to planId', () {
        expect(WorkoutPlanMapper.toRecord(detail).planId, 'plan-99');
      });

      test('maps name', () {
        expect(WorkoutPlanMapper.toRecord(detail).name, 'Full Body');
      });

      test('maps createdAt', () {
        expect(WorkoutPlanMapper.toRecord(detail).createdAt, createdAt);
      });

      test('maps exercises', () {
        final record = WorkoutPlanMapper.toRecord(detail);
        expect(record.planExercises.length, 1);
        expect(record.planExercises[0].exerciseId, 'ex-1');
        expect(record.planExercises[0].targetWeight, 100.0);
      });

      test('updatedAt is set to a non-null value', () {
        expect(WorkoutPlanMapper.toRecord(detail).updatedAt, isNotNull);
      });

      test('roundtrip: toRecord then toDetailFromRecord preserves data', () {
        final record = WorkoutPlanMapper.toRecord(detail);
        final restored = WorkoutPlanMapper.toDetailFromRecord(record);
        expect(restored.id, detail.id);
        expect(restored.name, detail.name);
        expect(restored.exercises.length, detail.exercises.length);
        expect(
          restored.exercises[0].targetWeight,
          detail.exercises[0].targetWeight,
        );
      });
    });
  });
}
