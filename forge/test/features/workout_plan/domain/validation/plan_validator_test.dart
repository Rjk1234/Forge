import 'package:flutter_test/flutter_test.dart';
import 'package:forge/core/enums/exercise_type.dart';
import 'package:forge/features/workout_plan/domain/entities/plan_exercise.dart';
import 'package:forge/features/workout_plan/domain/entities/workout_plan_detail.dart';
import 'package:forge/features/workout_plan/domain/validation/plan_validator.dart';
import 'package:forge/features/workout_plan/domain/validation/plan_violation.dart';

WorkoutPlanDetail _plan({
  String name = 'Push Day',
  List<PlanExercise>? exercises,
}) => WorkoutPlanDetail(
  id: 'p1',
  name: name,
  createdAt: DateTime(2026, 1, 1),
  exercises: exercises ?? [_weighted()],
);

PlanExercise _weighted({
  int sets = 3,
  int? reps = 10,
  double? weight = 60,
  int? durationSec,
  int rest = 60,
}) => PlanExercise(
  exerciseId: 'ex_bench',
  exerciseName: 'Bench Press',
  type: ExerciseType.weighted,
  targetSets: sets,
  restPeriodSec: rest,
  targetRepetitions: reps,
  targetWeight: weight,
  targetDurationSec: durationSec,
);

List<PlanViolationType> _types(WorkoutPlanDetail plan) =>
    const PlanValidator().validate(plan).map((v) => v.type).toList();

void main() {
  test('a fully valid plan has no violations', () {
    expect(_types(_plan()), isEmpty);
  });

  test('a plan without exercises is rejected', () {
    expect(_types(_plan(exercises: const [])), [
      PlanViolationType.exercisesRequired,
    ]);
  });

  test('blank and whitespace names are rejected', () {
    expect(_types(_plan(name: '')), [PlanViolationType.nameInvalid]);
    expect(_types(_plan(name: '   ')), [PlanViolationType.nameInvalid]);
  });

  test('sets, reps, weight and rest outside the rules are rejected', () {
    expect(_types(_plan(exercises: [_weighted(sets: 0)])), [
      PlanViolationType.setsInvalid,
    ]);
    expect(_types(_plan(exercises: [_weighted(reps: 0)])), [
      PlanViolationType.repetitionsInvalid,
    ]);
    expect(_types(_plan(exercises: [_weighted(weight: -5)])), [
      PlanViolationType.weightInvalid,
    ]);
    expect(_types(_plan(exercises: [_weighted(weight: 0)])), [
      PlanViolationType.weightInvalid,
    ]);
    expect(_types(_plan(exercises: [_weighted(weight: double.infinity)])), [
      PlanViolationType.weightInvalid,
    ]);
    expect(_types(_plan(exercises: [_weighted(rest: -1)])), [
      PlanViolationType.restInvalid,
    ]);
  });

  test('rest of zero is valid', () {
    expect(_types(_plan(exercises: [_weighted(rest: 0)])), isEmpty);
  });

  test('a weighted exercise needs reps and weight', () {
    expect(_types(_plan(exercises: [_weighted(reps: null, weight: null)])), [
      PlanViolationType.repetitionsInvalid,
      PlanViolationType.weightInvalid,
    ]);
  });

  test('a time-based exercise needs a duration and no reps or weight', () {
    const timed = PlanExercise(
      exerciseId: 'ex_plank',
      exerciseName: 'Plank',
      type: ExerciseType.timeBased,
      targetSets: 1,
      restPeriodSec: 30,
      targetDurationSec: 30,
    );
    expect(_types(_plan(exercises: const [timed])), isEmpty);

    const noDuration = PlanExercise(
      exerciseId: 'ex_plank',
      exerciseName: 'Plank',
      type: ExerciseType.timeBased,
      targetSets: 1,
      restPeriodSec: 30,
    );
    expect(_types(_plan(exercises: const [noDuration])), [
      PlanViolationType.durationInvalid,
    ]);
  });

  test('a field that does not belong to the exercise type is flagged', () {
    const bodyweightWithWeight = PlanExercise(
      exerciseId: 'ex_push_up',
      exerciseName: 'Push-Up',
      type: ExerciseType.bodyweight,
      targetSets: 2,
      restPeriodSec: 30,
      targetRepetitions: 15,
      targetWeight: 10,
    );
    expect(_types(_plan(exercises: const [bodyweightWithWeight])), [
      PlanViolationType.unexpectedField,
    ]);
  });

  test('violations carry the index of the offending exercise', () {
    final violations = const PlanValidator().validate(
      _plan(exercises: [_weighted(), _weighted(sets: 0)]),
    );
    expect(violations.single.exerciseIndex, 1);
  });
}
