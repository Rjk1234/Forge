import 'package:drift/drift.dart';
import 'package:forge/core/enums/exercise_type.dart';

/// Developer-seeded exercise catalogue; read-only from the client.
@DataClassName('ExerciseRow')
class Exercises extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get type => textEnum<ExerciseType>()();
  TextColumn get muscleGroup => text().nullable()();
  TextColumn get description => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
