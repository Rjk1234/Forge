import 'package:flutter_test/flutter_test.dart';
import 'package:forge/core/enums/exercise_type.dart';
import 'package:forge/core/exceptions/app_exception.dart';
import 'package:forge/features/exercise/data/datasources/exercise_local_data_source.dart';
import 'package:forge/features/exercise/data/models/exercise_record.dart';
import 'package:forge/features/exercise/data/repositories/exercise_repository_impl.dart';

class _FakeDataSource implements ExerciseLocalDataSource {
  final List<ExerciseRecord>? models;
  final bool throwOnGet;

  _FakeDataSource({this.models, this.throwOnGet = false});

  @override
  Future<List<ExerciseRecord>> getAllExercises() async {
    if (throwOnGet) throw Exception('database read failed');
    return models ?? [];
  }

  @override
  Future<ExerciseRecord?> getExerciseById(String id) async => null;

  @override
  Future<void> seedExercises(List<ExerciseRecord> exercises) async {}
}

void main() {
  final benchModel = ExerciseRecord(
    id: 'ex_bench',
    name: 'Bench Press',
    type: ExerciseType.weighted,
  );

  group('ExerciseRepositoryImpl', () {
    test('returns Right with mapped exercises on success', () async {
      final repo = ExerciseRepositoryImpl(
        dataSource: _FakeDataSource(models: [benchModel]),
      );
      final result = await repo.getExercises();

      expect(result.isRight(), isTrue);
      result.fold((_) => fail('Expected Right'), (exercises) {
        expect(exercises.length, 1);
        expect(exercises.first.id, 'ex_bench');
        expect(exercises.first.name, 'Bench Press');
        expect(exercises.first.type, ExerciseType.weighted);
      });
    });

    test('returns Right with empty list when catalogue is empty', () async {
      final repo = ExerciseRepositoryImpl(
        dataSource: _FakeDataSource(models: []),
      );
      final result = await repo.getExercises();

      result.fold(
        (_) => fail('Expected Right'),
        (exercises) => expect(exercises, isEmpty),
      );
    });

    test('returns Left(CacheException) when data source throws', () async {
      final repo = ExerciseRepositoryImpl(
        dataSource: _FakeDataSource(throwOnGet: true),
      );
      final result = await repo.getExercises();

      expect(result.isLeft(), isTrue);
      result.fold((e) {
        expect(e, isA<CacheException>());
        expect(e.message, "Couldn't load the exercise catalogue");
      }, (_) => fail('Expected Left'));
    });

    test('maps multiple exercises of all types correctly', () async {
      final models = [
        ExerciseRecord(id: 'w', name: 'Deadlift', type: ExerciseType.weighted),
        ExerciseRecord(id: 't', name: 'Plank', type: ExerciseType.timeBased),
        ExerciseRecord(id: 'b', name: 'Push-up', type: ExerciseType.bodyweight),
      ];
      final repo = ExerciseRepositoryImpl(
        dataSource: _FakeDataSource(models: models),
      );
      final result = await repo.getExercises();

      result.fold((_) => fail('Expected Right'), (exercises) {
        expect(exercises.length, 3);
        expect(exercises[0].type, ExerciseType.weighted);
        expect(exercises[1].type, ExerciseType.timeBased);
        expect(exercises[2].type, ExerciseType.bodyweight);
      });
    });
  });
}
