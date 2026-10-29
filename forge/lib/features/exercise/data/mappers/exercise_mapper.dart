import 'package:forge/features/exercise/data/models/exercise_record.dart';
import 'package:forge/features/exercise/domain/entities/exercise.dart';

class ExerciseMapper {
  const ExerciseMapper._();

  static Exercise fromRecord(ExerciseRecord model) =>
      Exercise(id: model.id, name: model.name, type: model.type);
}
