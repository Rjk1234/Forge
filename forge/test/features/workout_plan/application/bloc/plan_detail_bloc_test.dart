import 'package:flutter_test/flutter_test.dart';
import 'package:forge/core/enums/exercise_type.dart';
import 'package:forge/core/exceptions/app_exception.dart';
import 'package:forge/features/workout_plan/application/bloc/plan_detail_bloc.dart';
import 'package:forge/features/workout_plan/application/bloc/plan_detail_event.dart';
import 'package:forge/features/workout_plan/application/bloc/plan_detail_state.dart';
import 'package:forge/features/workout_plan/domain/entities/plan_exercise.dart';
import 'package:forge/features/workout_plan/domain/entities/workout_plan.dart';
import 'package:forge/features/workout_plan/domain/entities/workout_plan_detail.dart';
import 'package:forge/features/workout_plan/domain/repositories/workout_plan_repository.dart';
import 'package:forge/features/workout_plan/domain/usecases/get_workout_plan_by_id_usecase.dart';
import 'package:fpdart/fpdart.dart';

// ---------------------------------------------------------------------------
// Fake repository
// ---------------------------------------------------------------------------

class _FakeRepo implements WorkoutPlanRepository {
  _FakeRepo({Either<AppException, WorkoutPlanDetail>? getResult})
    : _getResult = getResult ?? Right(_plan());

  final Either<AppException, WorkoutPlanDetail> _getResult;

  @override
  Future<Either<AppException, List<WorkoutPlan>>> getAllPlans() async =>
      const Right([]);

  @override
  Future<Either<AppException, WorkoutPlanDetail>> getPlanById(
    String planId,
  ) async => _getResult;

  @override
  Future<Either<AppException, WorkoutPlanDetail>> savePlan(
    WorkoutPlanDetail plan,
  ) async => Right(plan);

  @override
  Future<Either<AppException, void>> deletePlan(String planId) async =>
      const Right(null);
}

WorkoutPlanDetail _plan() => WorkoutPlanDetail(
  id: 'plan-1',
  name: 'Push Day',
  createdAt: DateTime(2024, 1, 1),
  exercises: const [
    PlanExercise(
      exerciseId: 'ex-1',
      exerciseName: 'Bench Press',
      type: ExerciseType.weighted,
      targetSets: 4,
      restPeriodSec: 90,
      targetRepetitions: 8,
      targetWeight: 60.0,
    ),
  ],
);

PlanDetailBloc _bloc({Either<AppException, WorkoutPlanDetail>? getResult}) {
  final repo = _FakeRepo(getResult: getResult);
  return PlanDetailBloc(getWorkoutPlanById: GetWorkoutPlanByIdUseCase(repo));
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  group('PlanDetailBloc', () {
    test('initial state is PlanDetailInitial', () {
      final bloc = _bloc();
      expect(bloc.state, isA<PlanDetailInitial>());
      bloc.close();
    });

    test(
      'PlanDetailLoadRequested emits Loading then Loaded on success',
      () async {
        final bloc = _bloc();
        final states = <PlanDetailState>[];
        final sub = bloc.stream.listen(states.add);

        bloc.add(const PlanDetailLoadRequested(planId: 'plan-1'));
        await Future<void>.delayed(const Duration(milliseconds: 50));

        expect(states, [isA<PlanDetailLoading>(), isA<PlanDetailLoaded>()]);
        final loaded = states.last as PlanDetailLoaded;
        expect(loaded.plan.name, 'Push Day');

        await sub.cancel();
        await bloc.close();
      },
    );

    test(
      'PlanDetailLoadRequested emits Loading then NotFound on failure',
      () async {
        final bloc = _bloc(
          getResult: Left(CacheException(message: 'Plan not found')),
        );
        final states = <PlanDetailState>[];
        final sub = bloc.stream.listen(states.add);

        bloc.add(const PlanDetailLoadRequested(planId: 'missing'));
        await Future<void>.delayed(const Duration(milliseconds: 50));

        expect(states, [isA<PlanDetailLoading>(), isA<PlanDetailNotFound>()]);

        await sub.cancel();
        await bloc.close();
      },
    );

    test(
      'second PlanDetailLoadRequested after Loaded emits Loading then Loaded',
      () async {
        final bloc = _bloc();
        final states = <PlanDetailState>[];
        final sub = bloc.stream.listen(states.add);

        bloc.add(const PlanDetailLoadRequested(planId: 'plan-1'));
        await Future<void>.delayed(const Duration(milliseconds: 50));
        bloc.add(const PlanDetailLoadRequested(planId: 'plan-1'));
        await Future<void>.delayed(const Duration(milliseconds: 50));

        expect(states, [
          isA<PlanDetailLoading>(),
          isA<PlanDetailLoaded>(),
          isA<PlanDetailLoading>(),
          isA<PlanDetailLoaded>(),
        ]);

        await sub.cancel();
        await bloc.close();
      },
    );

    group('shouldShowStartWorkout', () {
      Future<List<PlanDetailLoaded>> load(
        PlanDetailBloc bloc,
        List<PlanDetailLoadRequested> events,
      ) async {
        final loaded = <PlanDetailLoaded>[];
        final sub = bloc.stream.listen((s) {
          if (s is PlanDetailLoaded) loaded.add(s);
        });
        for (final event in events) {
          bloc.add(event);
          await Future<void>.delayed(const Duration(milliseconds: 50));
        }
        await sub.cancel();
        await bloc.close();
        return loaded;
      }

      test('is true by default', () async {
        final loaded = await load(_bloc(), [
          const PlanDetailLoadRequested(planId: 'plan-1'),
        ]);
        expect(loaded.single.shouldShowStartWorkout, isTrue);
      });

      test('is carried into the loaded state', () async {
        final loaded = await load(_bloc(), [
          const PlanDetailLoadRequested(
            planId: 'plan-1',
            shouldShowStartWorkout: false,
          ),
        ]);
        expect(loaded.single.shouldShowStartWorkout, isFalse);
      });

      test('a reload without a value keeps the previous one', () async {
        final loaded = await load(_bloc(), [
          const PlanDetailLoadRequested(
            planId: 'plan-1',
            shouldShowStartWorkout: false,
          ),
          const PlanDetailLoadRequested(planId: 'plan-1'),
        ]);
        expect(loaded.map((s) => s.shouldShowStartWorkout), [false, false]);
      });
    });
  });
}
