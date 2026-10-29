import 'package:flutter_test/flutter_test.dart';
import 'package:forge/features/workout_plan/domain/entities/workout_plan.dart';

void main() {
  final now = DateTime(2026, 9, 17, 10, 0);

  final plan = WorkoutPlan(
    id: 'plan_1',
    name: 'Push Day',
    exerciseCount: 3,
    createdAt: now,
  );

  group('WorkoutPlan', () {
    test('two instances with identical fields are equal', () {
      final other = WorkoutPlan(
        id: 'plan_1',
        name: 'Push Day',
        exerciseCount: 3,
        createdAt: now,
      );
      expect(plan, equals(other));
    });

    test('instances with different ids are not equal', () {
      final other = WorkoutPlan(
        id: 'plan_2',
        name: 'Push Day',
        exerciseCount: 3,
        createdAt: now,
      );
      expect(plan, isNot(equals(other)));
    });

    test('instances with different exerciseCounts are not equal', () {
      final other = WorkoutPlan(
        id: 'plan_1',
        name: 'Push Day',
        exerciseCount: 0,
        createdAt: now,
      );
      expect(plan, isNot(equals(other)));
    });

    test('props contains all fields', () {
      expect(plan.props, [
        plan.id,
        plan.name,
        plan.exerciseCount,
        plan.createdAt,
      ]);
    });

    test('exerciseCount of zero is valid', () {
      final empty = WorkoutPlan(
        id: 'plan_0',
        name: 'Empty',
        exerciseCount: 0,
        createdAt: now,
      );
      expect(empty.exerciseCount, 0);
    });

    test('exerciseCount of one is valid', () {
      final single = WorkoutPlan(
        id: 'plan_s',
        name: 'Single',
        exerciseCount: 1,
        createdAt: now,
      );
      expect(single.exerciseCount, 1);
    });
  });
}
