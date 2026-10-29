import 'package:flutter_test/flutter_test.dart';
import 'package:forge/core/database/exercise_seed_data.dart';
import 'package:forge/core/enums/exercise_type.dart';
import 'package:forge/core/services/exercise_seed_service.dart';
import 'package:forge/features/exercise/data/datasources/exercise_local_data_source.dart';
import 'package:forge/features/exercise/data/models/exercise_record.dart';

class _RecordingDataSource implements ExerciseLocalDataSource {
  List<ExerciseRecord>? seeded;

  @override
  Future<void> seedExercises(List<ExerciseRecord> exercises) async {
    seeded = exercises;
  }

  @override
  Future<List<ExerciseRecord>> getAllExercises() async => seeded ?? [];

  @override
  Future<ExerciseRecord?> getExerciseById(String id) async => null;
}

void main() {
  test('syncCatalogue hands the full seed list to the data source', () async {
    final dataSource = _RecordingDataSource();

    await ExerciseSeedService(dataSource: dataSource).syncCatalogue();

    expect(dataSource.seeded, isNotNull);
    expect(dataSource.seeded!.length, exerciseSeedData.length);
  });

  group('seed data', () {
    final seed = exerciseSeedData;

    test('ids and names are unique and non-empty', () {
      expect(seed.map((e) => e.id).toSet().length, seed.length);
      expect(seed.map((e) => e.name.toLowerCase()).toSet().length, seed.length);
      expect(seed.every((e) => e.id.isNotEmpty && e.name.isNotEmpty), isTrue);
    });

    test('covers every exercise type', () {
      for (final type in ExerciseType.values) {
        expect(seed.any((e) => e.type == type), isTrue, reason: '$type');
      }
    });
  });
}
