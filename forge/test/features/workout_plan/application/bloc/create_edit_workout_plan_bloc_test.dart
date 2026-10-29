import '../../../../helpers/fake_exercise_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forge/core/enums/exercise_type.dart';
import 'package:forge/core/exceptions/app_exception.dart';
import 'package:forge/features/exercise/domain/entities/exercise.dart';
import 'package:forge/features/workout_plan/application/bloc/create_edit_workout_plan_bloc.dart';
import 'package:forge/features/workout_plan/application/bloc/create_edit_workout_plan_event.dart';
import 'package:forge/features/workout_plan/application/bloc/create_edit_workout_plan_state.dart';
import 'package:forge/features/workout_plan/application/bloc/plan_exercise_form_entry.dart';
import 'package:forge/features/workout_plan/domain/entities/plan_exercise.dart';
import 'package:forge/features/workout_plan/domain/entities/workout_plan.dart';
import 'package:forge/features/workout_plan/domain/entities/workout_plan_detail.dart';
import 'package:forge/features/workout_plan/domain/repositories/workout_plan_repository.dart';
import 'package:forge/features/workout_plan/domain/usecases/get_workout_plan_by_id_usecase.dart';
import 'package:forge/features/workout_plan/domain/usecases/save_workout_plan_usecase.dart';
import 'package:fpdart/fpdart.dart';
import 'package:forge/features/workout_plan/application/bloc/plan_field_error.dart';

// ---------------------------------------------------------------------------
// Fake repository
// ---------------------------------------------------------------------------

class _FakeRepo implements WorkoutPlanRepository {
  _FakeRepo({
    Either<AppException, WorkoutPlanDetail>? getResult,
    Either<AppException, WorkoutPlanDetail>? saveResult,
  }) : _getResult = getResult ?? Right(_defaultDetail()),
       _saveResult = saveResult ?? Right(_defaultDetail());

  final Either<AppException, WorkoutPlanDetail> _getResult;
  final Either<AppException, WorkoutPlanDetail> _saveResult;
  final List<WorkoutPlanDetail> savedPlans = [];

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
  ) async {
    savedPlans.add(plan);
    return _saveResult;
  }

  @override
  Future<Either<AppException, void>> deletePlan(String planId) async =>
      const Right(null);
}

WorkoutPlanDetail _defaultDetail({String id = 'plan-1'}) => WorkoutPlanDetail(
  id: id,
  name: 'Push Day',
  createdAt: DateTime(2024, 1, 1),
  exercises: const [
    PlanExercise(
      exerciseId: 'ex-1',
      exerciseName: 'Bench Press',
      type: ExerciseType.weighted,
      targetSets: 3,
      restPeriodSec: 90,
      targetRepetitions: 10,
      targetWeight: 60.0,
    ),
  ],
);

const _catalogue = [
  Exercise(id: 'ex-1', name: 'Bench Press', type: ExerciseType.weighted),
  Exercise(id: 'ex-2', name: 'Plank', type: ExerciseType.timeBased),
  Exercise(id: 'ex-3', name: 'Push Up', type: ExerciseType.bodyweight),
  Exercise(id: 'e1', name: 'Bench Press', type: ExerciseType.weighted),
  Exercise(id: 'e2', name: 'Squat', type: ExerciseType.weighted),
];

CreateEditWorkoutPlanBloc _bloc({
  Either<AppException, WorkoutPlanDetail>? getResult,
  Either<AppException, WorkoutPlanDetail>? saveResult,
}) {
  final repo = _FakeRepo(getResult: getResult, saveResult: saveResult);
  return CreateEditWorkoutPlanBloc(
    getWorkoutPlanById: GetWorkoutPlanByIdUseCase(repo),
    saveWorkoutPlan: SaveWorkoutPlanUseCase(
      repository: repo,
      exerciseRepository: const FakeExerciseRepository(_catalogue),
    ),
  );
}

// ---------------------------------------------------------------------------
// Common form state for Save tests
// ---------------------------------------------------------------------------

CreateEditPlanReady _validWeightedState({
  String planId = 'plan-1',
  String planName = 'Push Day',
}) => CreateEditPlanReady(
  planId: planId,
  planName: planName,
  isDirty: true,
  exercises: [
    const PlanExerciseFormEntry(
      exerciseId: 'ex-1',
      exerciseName: 'Bench Press',
      type: ExerciseType.weighted,
      sets: '3',
      repsOrDuration: '10',
      weight: '60',
      rest: '90',
    ),
  ],
);

const _weightedExercise = Exercise(
  id: 'ex-1',
  name: 'Bench Press',
  type: ExerciseType.weighted,
);

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  group('CreateEditWorkoutPlanBloc', () {
    group('CreateEditPlanInitialized — create mode', () {
      test('emits Ready with empty form when planId is null', () async {
        final bloc = _bloc();
        final states = <CreateEditWorkoutPlanState>[];
        final sub = bloc.stream.listen(states.add);

        bloc.add(const CreateEditPlanInitialized());
        await Future<void>.delayed(Duration.zero);
        await sub.cancel();
        await bloc.close();

        expect(states.length, 1);
        final ready = states[0] as CreateEditPlanReady;
        expect(ready.planName, '');
        expect(ready.exercises, isEmpty);
        expect(ready.isDirty, isFalse);
      });
    });

    group('CreateEditPlanInitialized — edit mode', () {
      test('emits Loading then Ready with plan data', () async {
        final bloc = _bloc(getResult: Right(_defaultDetail()));
        final states = <CreateEditWorkoutPlanState>[];
        final sub = bloc.stream.listen(states.add);

        bloc.add(const CreateEditPlanInitialized(planId: 'plan-1'));
        await Future<void>.delayed(Duration.zero);
        await sub.cancel();
        await bloc.close();

        expect(states[0], isA<CreateEditPlanLoading>());
        expect(states[1], isA<CreateEditPlanReady>());
        final ready = states[1] as CreateEditPlanReady;
        expect(ready.planName, 'Push Day');
        expect(ready.exercises.length, 1);
      });

      test('emits Loading then LoadError on failure', () async {
        final bloc = _bloc(
          getResult: Left(CacheException(message: 'Not found')),
        );
        final states = <CreateEditWorkoutPlanState>[];
        final sub = bloc.stream.listen(states.add);

        bloc.add(const CreateEditPlanInitialized(planId: 'bad'));
        await Future<void>.delayed(Duration.zero);
        await sub.cancel();
        await bloc.close();

        expect(states[0], isA<CreateEditPlanLoading>());
        expect(states[1], isA<CreateEditPlanLoadError>());
      });
    });

    group('PlanNameChanged', () {
      test('updates planName and sets isDirty', () async {
        final bloc = _bloc();
        bloc.emit(
          const CreateEditPlanReady(
            planId: 'p1',
            planName: '',
            exercises: [],
            isDirty: false,
          ),
        );

        final states = <CreateEditWorkoutPlanState>[];
        final sub = bloc.stream.listen(states.add);
        bloc.add(const PlanNameChanged('Push Day'));
        await Future<void>.delayed(Duration.zero);
        await sub.cancel();
        await bloc.close();

        final ready = states[0] as CreateEditPlanReady;
        expect(ready.planName, 'Push Day');
        expect(ready.isDirty, isTrue);
        expect(ready.nameError, isNull);
      });

      test('clears nameError on name change', () async {
        final bloc = _bloc();
        bloc.emit(
          const CreateEditPlanReady(
            planId: 'p1',
            planName: '',
            exercises: [],
            isDirty: true,
            nameError: PlanFieldError.nameRequired,
          ),
        );

        final states = <CreateEditWorkoutPlanState>[];
        final sub = bloc.stream.listen(states.add);
        bloc.add(const PlanNameChanged('Pull Day'));
        await Future<void>.delayed(Duration.zero);
        await sub.cancel();
        await bloc.close();

        final ready = states[0] as CreateEditPlanReady;
        expect(ready.nameError, isNull);
      });
    });

    group('ExerciseAdded', () {
      test('appends exercise and sets isDirty', () async {
        final bloc = _bloc();
        bloc.emit(
          const CreateEditPlanReady(
            planId: 'p1',
            planName: 'Test',
            exercises: [],
            isDirty: false,
          ),
        );

        final states = <CreateEditWorkoutPlanState>[];
        final sub = bloc.stream.listen(states.add);
        bloc.add(const ExerciseAdded(_weightedExercise));
        await Future<void>.delayed(Duration.zero);
        await sub.cancel();
        await bloc.close();

        final ready = states[0] as CreateEditPlanReady;
        expect(ready.exercises.length, 1);
        expect(ready.exercises[0].exerciseId, 'ex-1');
        expect(ready.isDirty, isTrue);
      });
    });

    group('ExerciseRemoved', () {
      test('removes exercise at index 0 and keeps index 1', () async {
        final bloc = _bloc();
        bloc.emit(
          CreateEditPlanReady(
            planId: 'p1',
            planName: 'Test',
            exercises: [
              const PlanExerciseFormEntry(
                exerciseId: 'e1',
                exerciseName: 'Bench',
                type: ExerciseType.weighted,
              ),
              const PlanExerciseFormEntry(
                exerciseId: 'e2',
                exerciseName: 'Row',
                type: ExerciseType.weighted,
              ),
            ],
            isDirty: false,
          ),
        );

        final states = <CreateEditWorkoutPlanState>[];
        final sub = bloc.stream.listen(states.add);
        bloc.add(const ExerciseRemoved(0));
        await Future<void>.delayed(Duration.zero);
        await sub.cancel();
        await bloc.close();

        final ready = states[0] as CreateEditPlanReady;
        expect(ready.exercises.length, 1);
        expect(ready.exercises[0].exerciseId, 'e2');
      });
    });

    group('ExerciseFieldChanged', () {
      test('updates sets value and clears setsError', () async {
        final bloc = _bloc();
        bloc.emit(
          CreateEditPlanReady(
            planId: 'p1',
            planName: 'Test',
            exercises: [
              const PlanExerciseFormEntry(
                exerciseId: 'e1',
                exerciseName: 'Bench',
                type: ExerciseType.weighted,
                setsError: PlanFieldError.setsInvalid,
              ),
            ],
            isDirty: false,
          ),
        );

        final states = <CreateEditWorkoutPlanState>[];
        final sub = bloc.stream.listen(states.add);
        bloc.add(
          const ExerciseFieldChanged(
            index: 0,
            field: ExerciseField.sets,
            value: '4',
          ),
        );
        await Future<void>.delayed(Duration.zero);
        await sub.cancel();
        await bloc.close();

        final ready = states[0] as CreateEditPlanReady;
        expect(ready.exercises[0].sets, '4');
        expect(ready.exercises[0].setsError, isNull);
      });
    });

    group('SaveRequested', () {
      test(
        'every rejected Save bumps the counter, even with equal errors',
        () async {
          final bloc = _bloc();
          bloc.emit(
            const CreateEditPlanReady(
              planId: 'p1',
              planName: '',
              exercises: [],
              isDirty: true,
            ),
          );

          final states = <CreateEditWorkoutPlanState>[];
          final sub = bloc.stream.listen(states.add);
          bloc.add(const SaveRequested());
          await Future<void>.delayed(Duration.zero);
          bloc.add(const SaveRequested());
          await Future<void>.delayed(Duration.zero);
          await sub.cancel();
          await bloc.close();

          expect(
            states.map((s) => (s as CreateEditPlanReady).rejectedSaveCount),
            [1, 2],
          );
        },
      );

      test('emits Ready with nameError when plan name is empty', () async {
        final bloc = _bloc();
        bloc.emit(
          const CreateEditPlanReady(
            planId: 'p1',
            planName: '',
            exercises: [],
            isDirty: true,
          ),
        );

        final states = <CreateEditWorkoutPlanState>[];
        final sub = bloc.stream.listen(states.add);
        bloc.add(const SaveRequested());
        await Future<void>.delayed(Duration.zero);
        await sub.cancel();
        await bloc.close();

        final ready = states[0] as CreateEditPlanReady;
        expect(ready.nameError, isNotNull);
      });

      test(
        'a plan without exercises is not saved and shows the error',
        () async {
          final bloc = _bloc();
          bloc.emit(
            const CreateEditPlanReady(
              planId: 'p1',
              planName: 'Push',
              exercises: [],
              isDirty: true,
            ),
          );

          final states = <CreateEditWorkoutPlanState>[];
          final sub = bloc.stream.listen(states.add);
          bloc.add(const SaveRequested());
          await Future<void>.delayed(Duration.zero);
          await sub.cancel();
          await bloc.close();

          expect(states, hasLength(1));
          final ready = states.single as CreateEditPlanReady;
          expect(ready.exercisesError, PlanFieldError.exercisesRequired);
        },
      );

      test('emits Saving then Saved on success', () async {
        final bloc = _bloc(saveResult: Right(_defaultDetail()));
        bloc.emit(_validWeightedState());

        final states = <CreateEditWorkoutPlanState>[];
        final sub = bloc.stream.listen(states.add);
        bloc.add(const SaveRequested());
        await Future<void>.delayed(Duration.zero);
        await sub.cancel();
        await bloc.close();

        expect(states[0], isA<CreateEditPlanSaving>());
        expect(states[1], isA<CreateEditPlanSaved>());
      });

      test('emits Saving then SaveFailure on repository error', () async {
        final bloc = _bloc(
          saveResult: Left(CacheException(message: 'IO error')),
        );
        bloc.emit(_validWeightedState());

        final states = <CreateEditWorkoutPlanState>[];
        final sub = bloc.stream.listen(states.add);
        bloc.add(const SaveRequested());
        await Future<void>.delayed(Duration.zero);
        await sub.cancel();
        await bloc.close();

        expect(states[0], isA<CreateEditPlanSaving>());
        expect(states[1], isA<CreateEditPlanSaveFailure>());
      });

      test('rest = 0 is valid (FR-019: non-negative integer)', () async {
        final bloc = _bloc(saveResult: Right(_defaultDetail()));
        bloc.emit(
          CreateEditPlanReady(
            planId: 'plan-1',
            planName: 'No Rest',
            isDirty: true,
            exercises: [
              const PlanExerciseFormEntry(
                exerciseId: 'ex-3',
                exerciseName: 'Push Up',
                type: ExerciseType.bodyweight,
                sets: '4',
                repsOrDuration: '20',
                rest: '0',
              ),
            ],
          ),
        );

        final states = <CreateEditWorkoutPlanState>[];
        final sub = bloc.stream.listen(states.add);
        bloc.add(const SaveRequested());
        await Future<void>.delayed(Duration.zero);
        await sub.cancel();
        await bloc.close();

        expect(states[0], isA<CreateEditPlanSaving>());
        expect(states[1], isA<CreateEditPlanSaved>());
      });

      test('timeBased 00:00 fails duration validation', () async {
        final bloc = _bloc();
        bloc.emit(
          CreateEditPlanReady(
            planId: 'plan-1',
            planName: 'Cardio',
            isDirty: true,
            exercises: [
              const PlanExerciseFormEntry(
                exerciseId: 'ex-2',
                exerciseName: 'Plank',
                type: ExerciseType.timeBased,
                sets: '3',
                repsOrDuration: '00:00',
                rest: '60',
              ),
            ],
          ),
        );

        final states = <CreateEditWorkoutPlanState>[];
        final sub = bloc.stream.listen(states.add);
        bloc.add(const SaveRequested());
        await Future<void>.delayed(Duration.zero);
        await sub.cancel();
        await bloc.close();

        final ready = states[0] as CreateEditPlanReady;
        expect(ready.exercises[0].repsOrDurationError, isNotNull);
      });

      test('timeBased 01:30 passes validation', () async {
        final bloc = _bloc(saveResult: Right(_defaultDetail()));
        bloc.emit(
          CreateEditPlanReady(
            planId: 'plan-1',
            planName: 'Cardio',
            isDirty: true,
            exercises: [
              const PlanExerciseFormEntry(
                exerciseId: 'ex-2',
                exerciseName: 'Plank',
                type: ExerciseType.timeBased,
                sets: '3',
                repsOrDuration: '01:30',
                rest: '60',
              ),
            ],
          ),
        );

        final states = <CreateEditWorkoutPlanState>[];
        final sub = bloc.stream.listen(states.add);
        bloc.add(const SaveRequested());
        await Future<void>.delayed(Duration.zero);
        await sub.cancel();
        await bloc.close();

        expect(states[0], isA<CreateEditPlanSaving>());
        expect(states[1], isA<CreateEditPlanSaved>());
      });
    });

    group('RetrySaveRequested', () {
      test('retries save from failure state and succeeds', () async {
        final bloc = _bloc(saveResult: Right(_defaultDetail()));
        bloc.emit(CreateEditPlanSaveFailure(readyState: _validWeightedState()));

        final states = <CreateEditWorkoutPlanState>[];
        final sub = bloc.stream.listen(states.add);
        bloc.add(const RetrySaveRequested());
        await Future<void>.delayed(Duration.zero);
        await sub.cancel();
        await bloc.close();

        expect(states[0], isA<CreateEditPlanSaving>());
        expect(states[1], isA<CreateEditPlanSaved>());
      });
    });
  });

  group('SaveRequested business rules', () {
    CreateEditWorkoutPlanBloc blocFor(_FakeRepo repo) =>
        CreateEditWorkoutPlanBloc(
          getWorkoutPlanById: GetWorkoutPlanByIdUseCase(repo),
          saveWorkoutPlan: SaveWorkoutPlanUseCase(
            repository: repo,
            exerciseRepository: const FakeExerciseRepository(_catalogue),
          ),
        );

    Future<List<CreateEditWorkoutPlanState>> save(
      CreateEditWorkoutPlanBloc bloc,
      CreateEditPlanReady state,
    ) async {
      bloc.emit(state);
      final states = <CreateEditWorkoutPlanState>[];
      final sub = bloc.stream.listen(states.add);
      bloc.add(const SaveRequested());
      await Future<void>.delayed(Duration.zero);
      await sub.cancel();
      await bloc.close();
      return states;
    }

    CreateEditPlanReady weightedWith({
      String name = 'Push Day',
      String sets = '3',
      String reps = '10',
      String weight = '60',
      String rest = '90',
    }) => CreateEditPlanReady(
      planId: 'plan-1',
      planName: name,
      isDirty: true,
      exercises: [
        PlanExerciseFormEntry(
          exerciseId: 'ex-1',
          exerciseName: 'Bench Press',
          type: ExerciseType.weighted,
          sets: sets,
          repsOrDuration: reps,
          weight: weight,
          rest: rest,
        ),
      ],
    );

    test('a whitespace-only name is rejected', () async {
      final repo = _FakeRepo();
      final states = await save(blocFor(repo), weightedWith(name: '   '));

      expect((states.single as CreateEditPlanReady).nameError, isNotNull);
      expect(repo.savedPlans, isEmpty);
    });

    test('the saved name is trimmed', () async {
      final repo = _FakeRepo();
      await save(blocFor(repo), weightedWith(name: '  Push Day  '));

      expect(repo.savedPlans.single.name, 'Push Day');
    });

    for (final (label, state) in <(String, CreateEditPlanReady)>[
      ('zero sets', weightedWith(sets: '0')),
      ('empty sets', weightedWith(sets: '')),
      ('sets above the limit', weightedWith(sets: '101')),
      ('zero reps', weightedWith(reps: '0')),
      ('empty reps', weightedWith(reps: '')),
      ('zero weight', weightedWith(weight: '0')),
      ('empty weight', weightedWith(weight: '')),
      ('weight above the limit', weightedWith(weight: '1000.1')),
      ('empty rest', weightedWith(rest: '')),
      ('rest above the limit', weightedWith(rest: '3601')),
    ]) {
      test('$label is rejected before anything is saved', () async {
        final repo = _FakeRepo();
        final states = await save(blocFor(repo), state);

        final ready = states.single as CreateEditPlanReady;
        expect(ready.canSave, isFalse);
        expect(repo.savedPlans, isEmpty);
      });
    }

    test('rest of zero is accepted', () async {
      final repo = _FakeRepo();
      await save(blocFor(repo), weightedWith(rest: '0'));

      expect(repo.savedPlans, hasLength(1));
    });

    test('editing keeps the original created date', () async {
      final created = DateTime(2024, 3, 4);
      final repo = _FakeRepo(
        getResult: Right(
          WorkoutPlanDetail(
            id: 'plan-1',
            name: 'Push Day',
            createdAt: created,
            exercises: const [
              PlanExercise(
                exerciseId: 'ex-1',
                exerciseName: 'Bench Press',
                type: ExerciseType.weighted,
                targetSets: 3,
                restPeriodSec: 90,
                targetRepetitions: 10,
                targetWeight: 60,
              ),
            ],
          ),
        ),
      );
      final bloc = blocFor(repo);

      bloc.add(const CreateEditPlanInitialized(planId: 'plan-1'));
      await Future<void>.delayed(Duration.zero);
      bloc.add(const SaveRequested());
      await Future<void>.delayed(Duration.zero);
      await bloc.close();

      expect(repo.savedPlans.single.createdAt, created);
    });
  });
}
