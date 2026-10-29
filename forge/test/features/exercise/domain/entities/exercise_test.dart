import 'package:flutter_test/flutter_test.dart';
import 'package:forge/core/enums/exercise_type.dart';
import 'package:forge/features/exercise/domain/entities/exercise.dart';

void main() {
  const id = 'ex_bench_press';
  const name = 'Bench Press';
  const type = ExerciseType.weighted;

  group('Exercise', () {
    test('equality holds for identical values', () {
      const a = Exercise(id: id, name: name, type: type);
      const b = Exercise(id: id, name: name, type: type);
      expect(a, equals(b));
    });

    test('inequality when id differs', () {
      const a = Exercise(id: 'ex_1', name: name, type: type);
      const b = Exercise(id: 'ex_2', name: name, type: type);
      expect(a, isNot(equals(b)));
    });

    test('inequality when name differs', () {
      const a = Exercise(id: id, name: 'Bench Press', type: type);
      const b = Exercise(id: id, name: 'Squat', type: type);
      expect(a, isNot(equals(b)));
    });

    test('inequality when type differs', () {
      const a = Exercise(id: id, name: name, type: ExerciseType.weighted);
      const b = Exercise(id: id, name: name, type: ExerciseType.bodyweight);
      expect(a, isNot(equals(b)));
    });

    test('props contains id, name, and type', () {
      const exercise = Exercise(id: id, name: name, type: type);
      expect(exercise.props, equals([id, name, type]));
    });
  });
}
