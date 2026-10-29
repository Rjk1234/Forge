import 'package:flutter_test/flutter_test.dart';
import 'package:forge/core/enums/exercise_type.dart';
import 'package:forge/features/exercise/data/mappers/exercise_mapper.dart';
import 'package:forge/features/exercise/data/models/exercise_record.dart';

void main() {
  group('ExerciseMapper.fromRecord', () {
    test('maps weighted exercise correctly', () {
      final model = ExerciseRecord(
        id: 'ex_bench',
        name: 'Bench Press',
        type: ExerciseType.weighted,
      );
      final exercise = ExerciseMapper.fromRecord(model);

      expect(exercise.id, 'ex_bench');
      expect(exercise.name, 'Bench Press');
      expect(exercise.type, ExerciseType.weighted);
    });

    test('maps timeBased exercise correctly', () {
      final model = ExerciseRecord(
        id: 'ex_plank',
        name: 'Plank',
        type: ExerciseType.timeBased,
      );
      final exercise = ExerciseMapper.fromRecord(model);

      expect(exercise.type, ExerciseType.timeBased);
    });

    test('maps bodyweight exercise correctly', () {
      final model = ExerciseRecord(
        id: 'ex_pushup',
        name: 'Push-up',
        type: ExerciseType.bodyweight,
      );
      final exercise = ExerciseMapper.fromRecord(model);

      expect(exercise.type, ExerciseType.bodyweight);
    });

    test('id and name are preserved exactly', () {
      final model = ExerciseRecord(
        id: 'ex_123',
        name: 'Romanian Deadlift',
        type: ExerciseType.weighted,
        muscleGroup: 'Hamstrings',
        description: 'Hip-hinge movement',
      );
      final exercise = ExerciseMapper.fromRecord(model);

      expect(exercise.id, 'ex_123');
      expect(exercise.name, 'Romanian Deadlift');
    });
  });
}
