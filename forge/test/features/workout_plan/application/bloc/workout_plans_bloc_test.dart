import 'package:flutter_test/flutter_test.dart';
import 'package:forge/core/exceptions/app_exception.dart';
import 'package:forge/features/workout_plan/application/bloc/workout_plans_bloc.dart';
import 'package:forge/features/workout_plan/application/bloc/workout_plans_event.dart';
import 'package:forge/features/workout_plan/application/bloc/workout_plans_state.dart';
import 'package:forge/features/workout_plan/domain/entities/workout_plan.dart';
import 'package:forge/features/workout_plan/domain/entities/workout_plan_detail.dart';
import 'package:forge/features/workout_plan/domain/repositories/workout_plan_repository.dart';
import 'package:forge/features/workout_plan/domain/usecases/get_workout_plans_usecase.dart';
import 'package:fpdart/fpdart.dart';

class _FakeRepository implements WorkoutPlanRepository {
  final Either<AppException, List<WorkoutPlan>> response;
  _FakeRepository(this.response);

  @override
  Future<Either<AppException, List<WorkoutPlan>>> getAllPlans() async =>
      response;

  @override
  Future<Either<AppException, WorkoutPlanDetail>> getPlanById(String planId) =>
      throw UnimplementedError();

  @override
  Future<Either<AppException, WorkoutPlanDetail>> savePlan(
    WorkoutPlanDetail plan,
  ) => throw UnimplementedError();

  @override
  Future<Either<AppException, void>> deletePlan(String planId) =>
      throw UnimplementedError();
}

GetWorkoutPlansUseCase _useCase(
  Either<AppException, List<WorkoutPlan>> response,
) => GetWorkoutPlansUseCase(repository: _FakeRepository(response));

final _now = DateTime(2026, 9, 17);

WorkoutPlan _plan(String id) =>
    WorkoutPlan(id: id, name: 'Plan $id', exerciseCount: 2, createdAt: _now);

void main() {
  group('WorkoutPlansBloc', () {
    test('initial state is WorkoutPlansInitial', () {
      final bloc = WorkoutPlansBloc(getWorkoutPlans: _useCase(Right([])));
      expect(bloc.state, isA<WorkoutPlansInitial>());
      bloc.close();
    });

    test(
      'Initial + LoadRequested emits Loading then Populated when plans exist',
      () async {
        final plans = [_plan('p1'), _plan('p2')];
        final bloc = WorkoutPlansBloc(getWorkoutPlans: _useCase(Right(plans)));

        final states = <WorkoutPlansState>[];
        final sub = bloc.stream.listen(states.add);

        bloc.add(const WorkoutPlansLoadRequested());
        await Future<void>.delayed(Duration.zero);
        await sub.cancel();
        await bloc.close();

        expect(states[0], isA<WorkoutPlansLoading>());
        expect(states[1], isA<WorkoutPlansPopulated>());
        expect((states[1] as WorkoutPlansPopulated).plans, plans);
      },
    );

    test(
      'Initial + LoadRequested emits Loading then Empty when no plans',
      () async {
        final bloc = WorkoutPlansBloc(
          getWorkoutPlans: _useCase(const Right([])),
        );

        final states = <WorkoutPlansState>[];
        final sub = bloc.stream.listen(states.add);

        bloc.add(const WorkoutPlansLoadRequested());
        await Future<void>.delayed(Duration.zero);
        await sub.cancel();
        await bloc.close();

        expect(states[0], isA<WorkoutPlansLoading>());
        expect(states[1], isA<WorkoutPlansEmpty>());
      },
    );

    test(
      'Initial + LoadRequested emits Loading then Error on failure',
      () async {
        final bloc = WorkoutPlansBloc(
          getWorkoutPlans: _useCase(
            Left(CacheException(message: 'Read failed')),
          ),
        );

        final states = <WorkoutPlansState>[];
        final sub = bloc.stream.listen(states.add);

        bloc.add(const WorkoutPlansLoadRequested());
        await Future<void>.delayed(Duration.zero);
        await sub.cancel();
        await bloc.close();

        expect(states[0], isA<WorkoutPlansLoading>());
        expect(states[1], isA<WorkoutPlansError>());
      },
    );

    test(
      'Populated + LoadRequested does NOT emit Loading (optimistic re-read)',
      () async {
        final plans = [_plan('p1')];
        final bloc = WorkoutPlansBloc(getWorkoutPlans: _useCase(Right(plans)));

        // First load — bring to Populated
        bloc.add(const WorkoutPlansLoadRequested());
        await Future<void>.delayed(Duration.zero);
        expect(bloc.state, isA<WorkoutPlansPopulated>());

        final states = <WorkoutPlansState>[];
        final sub = bloc.stream.listen(states.add);

        // Second load — should NOT emit Loading
        bloc.add(const WorkoutPlansLoadRequested());
        await Future<void>.delayed(Duration.zero);
        await sub.cancel();
        await bloc.close();

        expect(states.whereType<WorkoutPlansLoading>(), isEmpty);
        // Equatable prevents re-emitting an identical state, so the stream may
        // stay silent. The bloc must remain Populated — never drop to Loading.
        expect(bloc.state, isA<WorkoutPlansPopulated>());
      },
    );

    test(
      'Empty + LoadRequested does NOT emit Loading (optimistic re-read)',
      () async {
        final bloc = WorkoutPlansBloc(
          getWorkoutPlans: _useCase(const Right([])),
        );

        // First load — bring to Empty
        bloc.add(const WorkoutPlansLoadRequested());
        await Future<void>.delayed(Duration.zero);
        expect(bloc.state, isA<WorkoutPlansEmpty>());

        final states = <WorkoutPlansState>[];
        final sub = bloc.stream.listen(states.add);

        // Second load — should NOT emit Loading
        bloc.add(const WorkoutPlansLoadRequested());
        await Future<void>.delayed(Duration.zero);
        await sub.cancel();
        await bloc.close();

        expect(states.whereType<WorkoutPlansLoading>(), isEmpty);
        // Equatable prevents re-emitting an identical state; bloc stays Empty.
        expect(bloc.state, isA<WorkoutPlansEmpty>());
      },
    );

    test(
      'Error + LoadRequested DOES emit Loading (retry shows skeleton)',
      () async {
        var callCount = 0;
        final responses = <Either<AppException, List<WorkoutPlan>>>[
          Left(CacheException(message: 'Read failed')),
          Right([_plan('p1')]),
        ];

        final repo = _Repository(() => responses[callCount++]);
        final bloc = WorkoutPlansBloc(
          getWorkoutPlans: GetWorkoutPlansUseCase(repository: repo),
        );

        // First load — go to Error
        bloc.add(const WorkoutPlansLoadRequested());
        await Future<void>.delayed(Duration.zero);
        expect(bloc.state, isA<WorkoutPlansError>());

        final states = <WorkoutPlansState>[];
        final sub = bloc.stream.listen(states.add);

        // Retry — must emit Loading first
        bloc.add(const WorkoutPlansLoadRequested());
        await Future<void>.delayed(Duration.zero);
        await sub.cancel();
        await bloc.close();

        expect(states[0], isA<WorkoutPlansLoading>());
        expect(states[1], isA<WorkoutPlansPopulated>());
      },
    );
  });
}

class _Repository implements WorkoutPlanRepository {
  final Either<AppException, List<WorkoutPlan>> Function() _next;
  _Repository(this._next);

  @override
  Future<Either<AppException, List<WorkoutPlan>>> getAllPlans() async =>
      _next();

  @override
  Future<Either<AppException, WorkoutPlanDetail>> getPlanById(String planId) =>
      throw UnimplementedError();

  @override
  Future<Either<AppException, WorkoutPlanDetail>> savePlan(
    WorkoutPlanDetail plan,
  ) => throw UnimplementedError();

  @override
  Future<Either<AppException, void>> deletePlan(String planId) =>
      throw UnimplementedError();
}
