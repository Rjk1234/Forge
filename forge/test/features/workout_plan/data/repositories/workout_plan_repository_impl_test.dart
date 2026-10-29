import 'package:flutter_test/flutter_test.dart';
import 'package:forge/core/enums/exercise_type.dart';
import 'package:forge/core/exceptions/app_exception.dart';
import 'package:forge/features/workout_plan/data/datasources/workout_plan_local_data_source.dart';
import 'package:forge/features/workout_plan/data/models/plan_exercise_record.dart';
import 'package:forge/features/workout_plan/data/models/workout_plan_record.dart';
import 'package:forge/features/workout_plan/data/repositories/workout_plan_repository_impl.dart';
import 'package:forge/features/workout_plan/domain/entities/plan_exercise.dart';
import 'package:forge/features/workout_plan/domain/entities/workout_plan_detail.dart';

// ---------------------------------------------------------------------------
// Fake data source
// ---------------------------------------------------------------------------

class _FakeDataSource implements WorkoutPlanLocalDataSource {
  _FakeDataSource({
    this.getAllResult,
    this.getByIdResult,
    this.shouldThrow = false,
    this.throwOn = '',
  });

  final List<WorkoutPlanRecord> Function()? getAllResult;
  final WorkoutPlanRecord? Function(String)? getByIdResult;
  final bool shouldThrow;
  final String throwOn;

  WorkoutPlanRecord? lastSaved;

  @override
  Future<List<WorkoutPlanRecord>> getAllPlans() async {
    if (shouldThrow && (throwOn.isEmpty || throwOn == 'getAll')) {
      throw Exception('database error');
    }
    return getAllResult?.call() ?? [];
  }

  @override
  Future<WorkoutPlanRecord?> getPlanById(String planId) async {
    if (shouldThrow && (throwOn.isEmpty || throwOn == 'getById')) {
      throw Exception('database error');
    }
    return getByIdResult?.call(planId);
  }

  @override
  Future<void> savePlan(WorkoutPlanRecord model) async {
    if (shouldThrow && (throwOn.isEmpty || throwOn == 'save')) {
      throw Exception('IO error');
    }
    lastSaved = model;
  }

  @override
  Future<void> deletePlan(String planId) async {
    if (shouldThrow && (throwOn.isEmpty || throwOn == 'delete')) {
      throw Exception('IO error');
    }
  }
}

// ---------------------------------------------------------------------------
// Fixtures
// ---------------------------------------------------------------------------

WorkoutPlanRecord _planRecord({
  String planId = 'p1',
  String name = 'Push',
  DateTime? createdAt,
}) => WorkoutPlanRecord(
  planId: planId,
  name: name,
  planExercises: [
    PlanExerciseRecord(
      exerciseId: 'e1',
      exerciseName: 'Bench',
      type: ExerciseType.weighted,
      targetSets: 3,
      targetRepetitions: 10,
      targetWeight: 60.0,
      restPeriodSec: 90,
    ),
  ],
  createdAt: createdAt ?? DateTime(2024, 1, 1),
  updatedAt: DateTime(2024, 1, 2),
);

WorkoutPlanDetail _detailModel({String id = 'p1', String name = 'Push'}) =>
    WorkoutPlanDetail(
      id: id,
      name: name,
      createdAt: DateTime(2024, 1, 1),
      exercises: const [
        PlanExercise(
          exerciseId: 'e1',
          exerciseName: 'Bench',
          type: ExerciseType.weighted,
          targetSets: 3,
          restPeriodSec: 90,
          targetRepetitions: 10,
          targetWeight: 60.0,
        ),
      ],
    );

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

WorkoutPlanRepositoryImpl _makeRepo({_FakeDataSource? ds}) =>
    WorkoutPlanRepositoryImpl(dataSource: ds ?? _FakeDataSource());

void main() {
  group('WorkoutPlanRepositoryImpl', () {
    group('getAllPlans', () {
      test('returns Right with plans sorted newest-first', () async {
        final older = _planRecord(
          planId: 'old',
          createdAt: DateTime(2023, 1, 1),
        );
        final newer = _planRecord(
          planId: 'new',
          createdAt: DateTime(2024, 1, 1),
        );
        final ds = _FakeDataSource(getAllResult: () => [older, newer]);
        final repo = _makeRepo(ds: ds);

        final result = await repo.getAllPlans();

        expect(result.isRight(), isTrue);
        final plans = result.getOrElse((_) => []);
        expect(plans.first.id, 'new');
        expect(plans.last.id, 'old');
      });

      test('returns Right(empty) when the data source returns an '
          'unmodifiable empty list', () async {
        final ds = _FakeDataSource(getAllResult: () => const []);
        final repo = _makeRepo(ds: ds);

        final result = await repo.getAllPlans();

        expect(result.getOrElse((_) => throw StateError('Left')), isEmpty);
      });

      test('returns Left(CacheException) when data source throws', () async {
        final ds = _FakeDataSource(shouldThrow: true, throwOn: 'getAll');
        final repo = _makeRepo(ds: ds);

        final result = await repo.getAllPlans();

        expect(result.isLeft(), isTrue);
        result.fold(
          (e) => expect(e, isA<CacheException>()),
          (_) => fail('Expected Left'),
        );
      });
    });

    group('getPlanById', () {
      test('returns Right(detail) when plan is found', () async {
        final model = _planRecord();
        final ds = _FakeDataSource(getByIdResult: (_) => model);
        final repo = _makeRepo(ds: ds);

        final result = await repo.getPlanById('p1');

        expect(result.isRight(), isTrue);
        result.fold((_) => fail('Expected Right'), (detail) {
          expect(detail.id, 'p1');
          expect(detail.exercises.length, 1);
        });
      });

      test(
        'returns Left(CacheException) when plan is not found (null)',
        () async {
          final ds = _FakeDataSource(getByIdResult: (_) => null);
          final repo = _makeRepo(ds: ds);

          final result = await repo.getPlanById('missing');

          expect(result.isLeft(), isTrue);
          result.fold(
            (e) => expect(e, isA<CacheException>()),
            (_) => fail('Expected Left'),
          );
        },
      );

      test('returns Left(CacheException) when data source throws', () async {
        final ds = _FakeDataSource(shouldThrow: true, throwOn: 'getById');
        final repo = _makeRepo(ds: ds);

        final result = await repo.getPlanById('p1');

        expect(result.isLeft(), isTrue);
        result.fold(
          (e) => expect(e, isA<CacheException>()),
          (_) => fail('Expected Left'),
        );
      });
    });

    group('savePlan', () {
      test('returns Right(plan) on success', () async {
        final ds = _FakeDataSource();
        final repo = _makeRepo(ds: ds);
        final detail = _detailModel();

        final result = await repo.savePlan(detail);

        expect(result.isRight(), isTrue);
        result.fold(
          (_) => fail('Expected Right'),
          (saved) => expect(saved.id, detail.id),
        );
      });

      test('passes correct planId to data source', () async {
        final ds = _FakeDataSource();
        final repo = _makeRepo(ds: ds);
        final detail = _detailModel(id: 'plan-save-test');

        await repo.savePlan(detail);

        expect(ds.lastSaved?.planId, 'plan-save-test');
      });

      test('returns Left(CacheException) when data source throws', () async {
        final ds = _FakeDataSource(shouldThrow: true, throwOn: 'save');
        final repo = _makeRepo(ds: ds);

        final result = await repo.savePlan(_detailModel());

        expect(result.isLeft(), isTrue);
        result.fold(
          (e) => expect(e, isA<CacheException>()),
          (_) => fail('Expected Left'),
        );
      });
    });

    group('deletePlan', () {
      test('returns Right(null) on success', () async {
        final repo = _makeRepo();
        final result = await repo.deletePlan('p1');
        expect(result.isRight(), isTrue);
      });

      test(
        'returns Left(CacheException) when plan data source throws',
        () async {
          final ds = _FakeDataSource(shouldThrow: true, throwOn: 'delete');
          final repo = _makeRepo(ds: ds);

          final result = await repo.deletePlan('p1');

          expect(result.isLeft(), isTrue);
          result.fold(
            (e) => expect(e, isA<CacheException>()),
            (_) => fail('Expected Left'),
          );
        },
      );
    });
  });
}
