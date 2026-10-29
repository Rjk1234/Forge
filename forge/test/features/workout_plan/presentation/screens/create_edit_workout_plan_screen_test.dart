import 'package:forge/core/validation/workout_value_rules.dart';
import 'package:forge/features/exercise/domain/entities/exercise.dart';
import '../../../../helpers/fake_exercise_repository.dart';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:forge/features/workout_plan/application/bloc/create_edit_workout_plan_event.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forge/core/enums/exercise_type.dart';
import 'package:forge/core/exceptions/app_exception.dart';
import 'package:forge/core/theme/app_theme.dart';
import 'package:forge/features/workout_plan/application/bloc/create_edit_workout_plan_bloc.dart';
import 'package:forge/features/workout_plan/application/bloc/create_edit_workout_plan_state.dart';
import 'package:forge/features/workout_plan/application/bloc/plan_exercise_form_entry.dart';
import 'package:forge/features/workout_plan/domain/entities/plan_exercise.dart';
import 'package:forge/features/workout_plan/domain/entities/workout_plan.dart';
import 'package:forge/features/workout_plan/domain/entities/workout_plan_detail.dart';
import 'package:forge/features/workout_plan/domain/repositories/workout_plan_repository.dart';
import 'package:forge/features/workout_plan/domain/usecases/get_workout_plan_by_id_usecase.dart';
import 'package:forge/features/workout_plan/domain/usecases/save_workout_plan_usecase.dart';
import 'package:forge/features/workout_plan/presentation/screens/create_edit_workout_plan_screen.dart';
import 'package:forge/features/workout_plan/presentation/screens/plan_detail_screen.dart';
import 'package:forge/features/workout_plan/presentation/widgets/discard_dialog.dart';
import 'package:forge/features/workout_plan/presentation/widgets/exercise_card.dart';
import 'package:forge/features/workout_plan/presentation/widgets/plan_name_field.dart';
import 'package:forge/features/workout_plan/presentation/widgets/save_failure_banner.dart';
import 'package:fpdart/fpdart.dart';
import 'package:go_router/go_router.dart';
import '../../../../helpers/l10n.dart';
import 'package:forge/l10n/l10n.dart';
import 'package:forge/features/workout_plan/application/bloc/plan_field_error.dart';

// ---------------------------------------------------------------------------
// Fake repository
// ---------------------------------------------------------------------------

class _FakeRepo implements WorkoutPlanRepository {
  _FakeRepo({
    Either<AppException, WorkoutPlanDetail>? getResult,
    Either<AppException, WorkoutPlanDetail>? saveResult,
  }) : _getResult = getResult ?? Right(_emptyDetail()),
       _saveResult = saveResult ?? Right(_emptyDetail());

  final Either<AppException, WorkoutPlanDetail> _getResult;
  final Either<AppException, WorkoutPlanDetail> _saveResult;

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
  ) async => _saveResult;

  @override
  Future<Either<AppException, void>> deletePlan(String planId) async =>
      const Right(null);
}

WorkoutPlanDetail _emptyDetail() => WorkoutPlanDetail(
  id: 'plan-1',
  name: '',
  createdAt: DateTime(2024, 1, 1),
  exercises: const [],
);

WorkoutPlanDetail _filledDetail({List<PlanExercise> exercises = const []}) =>
    WorkoutPlanDetail(
      id: 'plan-1',
      name: 'Push Day',
      createdAt: DateTime(2024, 1, 1),
      exercises: exercises,
    );

// ---------------------------------------------------------------------------
// Bloc factory
// ---------------------------------------------------------------------------

const _catalogue = [
  Exercise(id: 'e-w', name: 'Bench Press', type: ExerciseType.weighted),
  Exercise(id: 'e-t', name: 'Plank', type: ExerciseType.timeBased),
  Exercise(id: 'e-b', name: 'Push Up', type: ExerciseType.bodyweight),
  Exercise(id: 'e1', name: 'Bench Press', type: ExerciseType.weighted),
  Exercise(id: 'e2', name: 'Plank', type: ExerciseType.timeBased),
  Exercise(id: 'e3', name: 'Push Up', type: ExerciseType.bodyweight),
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
// Widget harness
// ---------------------------------------------------------------------------

/// Builds a GoRouter that starts at /plans (parent) then goes to the
/// create/edit screen so that [context.pop()] has somewhere to return to.
Widget _harness(CreateEditWorkoutPlanBloc bloc, {String? planId}) {
  bloc.add(CreateEditPlanInitialized(planId: planId));
  final router = GoRouter(
    initialLocation: planId == null ? '/plans/create' : '/plans/$planId/edit',
    routes: [
      GoRoute(
        path: '/plans',
        builder: (_, __) => const Scaffold(body: Text('Plans')),
        routes: [
          GoRoute(
            path: 'create',
            builder: (context, state) =>
                BlocProvider<CreateEditWorkoutPlanBloc>.value(
                  value: bloc,
                  child: const CreateEditWorkoutPlanScreen(),
                ),
          ),
          GoRoute(
            path: PlanDetailScreen.routeSegment,
            name: PlanDetailScreen.routeName,
            builder: (_, s) =>
                Scaffold(body: Text('detail:${s.pathParameters['planId']}')),
            routes: [
              GoRoute(
                path: 'edit',
                builder: (context, state) =>
                    BlocProvider<CreateEditWorkoutPlanBloc>.value(
                      value: bloc,
                      child: CreateEditWorkoutPlanScreen(
                        planId: state.pathParameters['planId'],
                      ),
                    ),
              ),
            ],
          ),
          // Stub for exercise picker route so context.push doesn't crash.
          GoRoute(
            path: 'exercises',
            builder: (_, __) => const Scaffold(body: Text('Exercise Picker')),
          ),
        ],
      ),
    ],
  );

  return MaterialApp.router(
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    theme: AppTheme.darkTheme,
    routerConfig: router,
  );
}

/// Pumps the screen in create mode and waits for the Ready state.
Future<void> _pumpCreate(
  WidgetTester tester,
  CreateEditWorkoutPlanBloc bloc,
) async {
  await tester.pumpWidget(_harness(bloc));
  await tester.pump(); // processes CreateEditPlanInitialized
}

/// Pumps the screen in edit mode and waits for Ready state.
Future<void> _pumpEdit(
  WidgetTester tester,
  CreateEditWorkoutPlanBloc bloc, {
  String planId = 'plan-1',
}) async {
  await tester.pumpWidget(_harness(bloc, planId: planId));
  await tester.pump(); // processes Loading
  await tester.pump(); // processes Ready (async load completes)
}

// ---------------------------------------------------------------------------
// Shared form entry fixtures
// ---------------------------------------------------------------------------

PlanExerciseFormEntry _weightedEntry({
  String sets = '3',
  String reps = '10',
  String weight = '60',
  String rest = '90',
  PlanFieldError? setsError,
  PlanFieldError? repsOrDurationError,
  PlanFieldError? weightError,
}) => PlanExerciseFormEntry(
  exerciseId: 'e-w',
  exerciseName: 'Bench Press',
  type: ExerciseType.weighted,
  sets: sets,
  repsOrDuration: reps,
  weight: weight,
  rest: rest,
  setsError: setsError,
  repsOrDurationError: repsOrDurationError,
  weightError: weightError,
);

PlanExerciseFormEntry _timeBasedEntry() => const PlanExerciseFormEntry(
  exerciseId: 'e-t',
  exerciseName: 'Plank',
  type: ExerciseType.timeBased,
  sets: '3',
  repsOrDuration: '01:00',
  rest: '60',
);

PlanExerciseFormEntry _bodyweightEntry() => const PlanExerciseFormEntry(
  exerciseId: 'e-b',
  exerciseName: 'Push Up',
  type: ExerciseType.bodyweight,
  sets: '4',
  repsOrDuration: '20',
  rest: '0',
);

CreateEditPlanReady _readyWithExercises(
  List<PlanExerciseFormEntry> exercises, {
  String planName = 'Push Day',
  bool isDirty = false,
}) => CreateEditPlanReady(
  planId: 'plan-1',
  planName: planName,
  exercises: exercises,
  isDirty: isDirty,
);

// ---------------------------------------------------------------------------
// T023 — US1: Blank form (create mode)
// ---------------------------------------------------------------------------

void main() {
  group('T023 — US1: Blank form (create mode)', () {
    testWidgets('shows "Create Plan" in app bar title', (tester) async {
      final bloc = _bloc();
      await _pumpCreate(tester, bloc);

      expect(find.text(l10n.createPlanTitle), findsOneWidget);
      unawaited(bloc.close());
    });

    testWidgets('shows plan name field with correct hint', (tester) async {
      final bloc = _bloc();
      await _pumpCreate(tester, bloc);

      expect(find.text(l10n.planNameHint), findsOneWidget);
      unawaited(bloc.close());
    });

    testWidgets('shows empty-state message when no exercises', (tester) async {
      final bloc = _bloc();
      await _pumpCreate(tester, bloc);

      expect(find.text(l10n.noPlanExercisesMessage), findsOneWidget);
      unawaited(bloc.close());
    });

    testWidgets('shows Save Plan button', (tester) async {
      final bloc = _bloc();
      await _pumpCreate(tester, bloc);

      expect(find.text(l10n.savePlanButton), findsOneWidget);
      unawaited(bloc.close());
    });

    testWidgets('shows Add Exercise button', (tester) async {
      final bloc = _bloc();
      await _pumpCreate(tester, bloc);

      expect(find.text(l10n.addExerciseButton), findsOneWidget);
      unawaited(bloc.close());
    });

    testWidgets('typing in plan name field dispatches PlanNameChanged', (
      tester,
    ) async {
      final bloc = _bloc();
      await _pumpCreate(tester, bloc);

      await tester.enterText(find.byType(TextField).first, 'Leg Day');
      await tester.pump();

      // After the field change, bloc is dirty — name controller shows value
      expect(find.text('Leg Day'), findsOneWidget);
      unawaited(bloc.close());
    });
  });

  // -------------------------------------------------------------------------
  // T026 — US2: Edit mode pre-filled
  // -------------------------------------------------------------------------

  group('T026 — US2: Edit mode pre-filled', () {
    testWidgets('shows "Edit Plan" in app bar title', (tester) async {
      final bloc = _bloc(getResult: Right(_filledDetail()));
      await _pumpEdit(tester, bloc);

      expect(find.text(l10n.editPlanTitle), findsOneWidget);
      unawaited(bloc.close());
    });

    testWidgets('plan name field pre-filled with plan name', (tester) async {
      final bloc = _bloc(getResult: Right(_filledDetail()));
      await _pumpEdit(tester, bloc);

      expect(find.text('Push Day'), findsOneWidget);
      unawaited(bloc.close());
    });

    testWidgets(
      'weighted exercise card shows Sets, Reps, Weight, Rest fields',
      (tester) async {
        final bloc = _bloc(
          getResult: Right(
            _filledDetail(
              exercises: [
                const PlanExercise(
                  exerciseId: 'e1',
                  exerciseName: 'Bench Press',
                  type: ExerciseType.weighted,
                  targetSets: 3,
                  targetRepetitions: 10,
                  targetWeight: 60.0,
                  restPeriodSec: 90,
                ),
              ],
            ),
          ),
        );
        await _pumpEdit(tester, bloc);

        expect(find.byType(ExerciseCard), findsOneWidget);
        expect(find.text(l10n.setsLabel), findsOneWidget);
        expect(find.text(l10n.repsLabel), findsOneWidget);
        expect(find.text(l10n.weightLabel), findsOneWidget);
        expect(find.text(l10n.restLabel), findsOneWidget);
        unawaited(bloc.close());
      },
    );

    testWidgets('timeBased exercise card shows Duration field, no Weight', (
      tester,
    ) async {
      final bloc = _bloc(
        getResult: Right(
          _filledDetail(
            exercises: [
              const PlanExercise(
                exerciseId: 'e2',
                exerciseName: 'Plank',
                type: ExerciseType.timeBased,
                targetSets: 3,
                targetDurationSec: 60,
                restPeriodSec: 30,
              ),
            ],
          ),
        ),
      );
      await _pumpEdit(tester, bloc);

      expect(find.text(l10n.durationLabel), findsOneWidget);
      expect(find.text(l10n.weightLabel), findsNothing);
      unawaited(bloc.close());
    });

    testWidgets('bodyweight exercise card shows Reps field, no Weight', (
      tester,
    ) async {
      final bloc = _bloc(
        getResult: Right(
          _filledDetail(
            exercises: [
              const PlanExercise(
                exerciseId: 'e3',
                exerciseName: 'Push Up',
                type: ExerciseType.bodyweight,
                targetSets: 4,
                targetRepetitions: 20,
                restPeriodSec: 0,
              ),
            ],
          ),
        ),
      );
      await _pumpEdit(tester, bloc);

      expect(find.text(l10n.repsLabel), findsOneWidget);
      expect(find.text(l10n.weightLabel), findsNothing);
      unawaited(bloc.close());
    });

    testWidgets('LoadError state shows error message', (tester) async {
      final bloc = _bloc(getResult: Left(CacheException(message: 'Not found')));
      await _pumpEdit(tester, bloc);

      expect(find.text(l10n.planLoadError), findsOneWidget);
      unawaited(bloc.close());
    });
  });

  // -------------------------------------------------------------------------
  // T031 — US3: Exercise cards
  // -------------------------------------------------------------------------

  group('T031 — US3: Exercise cards render correctly', () {
    testWidgets('emitting Ready with exercises shows ExerciseCard', (
      tester,
    ) async {
      final bloc = _bloc();
      await _pumpCreate(tester, bloc);

      // Seed state with one weighted exercise
      bloc.emit(_readyWithExercises([_weightedEntry()]));
      await tester.pump();
      await tester.pump();

      expect(find.byType(ExerciseCard), findsOneWidget);
      expect(find.text('Bench Press'), findsOneWidget);
      unawaited(bloc.close());
    });

    testWidgets('weighted card shows Sets, Reps, Weight, Rest field labels', (
      tester,
    ) async {
      final bloc = _bloc();
      await _pumpCreate(tester, bloc);
      bloc.emit(_readyWithExercises([_weightedEntry()]));
      await tester.pump();
      await tester.pump();

      expect(find.text(l10n.setsLabel), findsOneWidget);
      expect(find.text(l10n.repsLabel), findsOneWidget);
      expect(find.text(l10n.weightLabel), findsOneWidget);
      expect(find.text(l10n.restLabel), findsOneWidget);
      unawaited(bloc.close());
    });

    testWidgets('timeBased card shows Duration label, no Weight label', (
      tester,
    ) async {
      final bloc = _bloc();
      await _pumpCreate(tester, bloc);
      bloc.emit(_readyWithExercises([_timeBasedEntry()]));
      await tester.pump();
      await tester.pump();

      expect(find.text(l10n.durationLabel), findsOneWidget);
      expect(find.text(l10n.weightLabel), findsNothing);
      unawaited(bloc.close());
    });

    testWidgets('bodyweight card shows Reps label, no Weight label', (
      tester,
    ) async {
      final bloc = _bloc();
      await _pumpCreate(tester, bloc);
      bloc.emit(_readyWithExercises([_bodyweightEntry()]));
      await tester.pump();
      await tester.pump();

      expect(find.text(l10n.repsLabel), findsOneWidget);
      expect(find.text(l10n.weightLabel), findsNothing);
      unawaited(bloc.close());
    });

    testWidgets('Remove (close) icon button present on exercise card', (
      tester,
    ) async {
      final bloc = _bloc();
      await _pumpCreate(tester, bloc);
      bloc.emit(_readyWithExercises([_weightedEntry()]));
      await tester.pump();
      await tester.pump();

      expect(find.widgetWithIcon(IconButton, Icons.close), findsOneWidget);
      unawaited(bloc.close());
    });

    testWidgets('removing all exercises restores empty-state message', (
      tester,
    ) async {
      final bloc = _bloc();
      await _pumpCreate(tester, bloc);
      bloc.emit(_readyWithExercises([_weightedEntry()]));
      await tester.pump();
      await tester.pump();

      // Transition to empty exercises
      bloc.emit(_readyWithExercises([]));
      await tester.pump();
      await tester.pump();

      expect(find.byType(ExerciseCard), findsNothing);
      expect(find.text(l10n.noPlanExercisesMessage), findsOneWidget);
      unawaited(bloc.close());
    });

    testWidgets('Add Exercise button visible below exercise list', (
      tester,
    ) async {
      final bloc = _bloc();
      await _pumpCreate(tester, bloc);
      bloc.emit(_readyWithExercises([_weightedEntry()]));
      await tester.pump();
      await tester.pump();

      expect(find.text(l10n.addExerciseButton), findsOneWidget);
      unawaited(bloc.close());
    });
  });

  // -------------------------------------------------------------------------
  // T035 — US4: Save flow
  // -------------------------------------------------------------------------

  group('T035 — US4: Save flow', () {
    testWidgets('Save Plan button visible in create mode', (tester) async {
      final bloc = _bloc();
      await _pumpCreate(tester, bloc);

      expect(find.text(l10n.savePlanButton), findsOneWidget);
      unawaited(bloc.close());
    });

    testWidgets('Saving state shows CircularProgressIndicator', (tester) async {
      final bloc = _bloc();
      await _pumpCreate(tester, bloc);

      final ready = _readyWithExercises([_weightedEntry()], planName: 'Push');
      bloc.emit(CreateEditPlanSaving(readyState: ready));
      await tester.pump();
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text(l10n.savePlanButton), findsNothing);
      unawaited(bloc.close());
    });

    testWidgets('Saving state dims the form with Opacity 0.6', (tester) async {
      final bloc = _bloc();
      await _pumpCreate(tester, bloc);

      final ready = _readyWithExercises([], planName: 'Push');
      bloc.emit(CreateEditPlanSaving(readyState: ready));
      await tester.pump();
      await tester.pump();

      // The body is wrapped in Opacity(0.6) during saving
      final opacities = tester
          .widgetList<Opacity>(find.byType(Opacity))
          .where((o) => o.opacity < 1.0)
          .toList();
      expect(opacities, isNotEmpty);
      unawaited(bloc.close());
    });

    testWidgets('Saved state navigates to plan detail route', (tester) async {
      final bloc = _bloc();
      await _pumpCreate(tester, bloc);

      bloc.emit(const CreateEditPlanSaved(savedPlanId: 'plan-42'));
      await tester.pumpAndSettle();

      expect(find.text('detail:plan-42'), findsOneWidget);
      unawaited(bloc.close());
    });
  });

  // -------------------------------------------------------------------------
  // T039 — US5: Inline validation errors
  // -------------------------------------------------------------------------

  group('T039 — US5: Inline validation errors', () {
    testWidgets('nameError shown below plan name field', (tester) async {
      final bloc = _bloc();
      await _pumpCreate(tester, bloc);

      bloc.emit(
        const CreateEditPlanReady(
          planId: 'p1',
          planName: '',
          exercises: [],
          isDirty: true,
          nameError: PlanFieldError.nameRequired,
        ),
      );
      await tester.pump();
      await tester.pump();

      expect(find.text(l10n.planNameRequiredError), findsOneWidget);
      unawaited(bloc.close());
    });

    testWidgets('setsError shown in exercise card', (tester) async {
      final bloc = _bloc();
      await _pumpCreate(tester, bloc);

      bloc.emit(
        _readyWithExercises([
          _weightedEntry(sets: '0', setsError: PlanFieldError.setsInvalid),
        ]),
      );
      await tester.pump();
      await tester.pump();

      expect(find.text(l10n.setsError(WorkoutLimits.maxSets)), findsOneWidget);
      unawaited(bloc.close());
    });

    testWidgets('weightError shown in weighted exercise card', (tester) async {
      final bloc = _bloc();
      await _pumpCreate(tester, bloc);

      bloc.emit(
        _readyWithExercises([
          _weightedEntry(
            weight: '0',
            weightError: PlanFieldError.weightInvalid,
          ),
        ]),
      );
      await tester.pump();
      await tester.pump();

      expect(
        find.text(l10n.weightError(WorkoutLimits.maxWeightKg.toInt())),
        findsOneWidget,
      );
      unawaited(bloc.close());
    });

    testWidgets('correcting field clears error', (tester) async {
      final bloc = _bloc();
      await _pumpCreate(tester, bloc);

      // Emit state with setsError
      bloc.emit(
        _readyWithExercises([
          _weightedEntry(setsError: PlanFieldError.setsInvalid),
        ]),
      );
      await tester.pump();
      await tester.pump();
      expect(find.text(l10n.setsError(WorkoutLimits.maxSets)), findsOneWidget);

      // Emit state with error cleared (simulates ExerciseFieldChanged clearing it)
      bloc.emit(_readyWithExercises([_weightedEntry()]));
      await tester.pump();
      await tester.pump();

      expect(find.text(l10n.setsError(WorkoutLimits.maxSets)), findsNothing);
      unawaited(bloc.close());
    });

    testWidgets('repsOrDurationError shown in timeBased card', (tester) async {
      final bloc = _bloc();
      await _pumpCreate(tester, bloc);

      bloc.emit(
        _readyWithExercises([
          const PlanExerciseFormEntry(
            exerciseId: 'e-t',
            exerciseName: 'Plank',
            type: ExerciseType.timeBased,
            sets: '3',
            repsOrDuration: '00:00',
            rest: '60',
            repsOrDurationError: PlanFieldError.durationInvalid,
          ),
        ]),
      );
      await tester.pump();
      await tester.pump();

      expect(find.text(l10n.durationError), findsOneWidget);
      unawaited(bloc.close());
    });
  });

  // -------------------------------------------------------------------------
  // T043 — US6: Unsaved changes guard
  // -------------------------------------------------------------------------

  group('T043 — US6: Unsaved changes guard', () {
    testWidgets('back button visible in app bar', (tester) async {
      final bloc = _bloc();
      await _pumpCreate(tester, bloc);

      expect(find.byIcon(Icons.chevron_left), findsOneWidget);
      unawaited(bloc.close());
    });

    testWidgets('clean form: back tap does NOT show DiscardDialog', (
      tester,
    ) async {
      final bloc = _bloc();
      await _pumpCreate(tester, bloc);

      // Clean (isDirty: false) — initState emits Ready(isDirty: false)
      await tester.tap(find.byIcon(Icons.chevron_left));
      await tester.pump();

      expect(find.byType(DiscardDialog), findsNothing);
      unawaited(bloc.close());
    });

    testWidgets('dirty form: back tap shows DiscardDialog', (tester) async {
      final bloc = _bloc();
      await _pumpCreate(tester, bloc);

      // Mark form dirty
      bloc.emit(
        const CreateEditPlanReady(
          planId: 'p1',
          planName: 'Test Plan',
          exercises: [],
          isDirty: true,
        ),
      );
      await tester.pump();
      await tester.pump();

      await tester.tap(find.byIcon(Icons.chevron_left));
      await tester.pump(); // starts async _showDiscardDialog

      expect(find.byType(DiscardDialog), findsOneWidget);
      unawaited(bloc.close());
    });

    testWidgets('DiscardDialog shows correct title and actions', (
      tester,
    ) async {
      final bloc = _bloc();
      await _pumpCreate(tester, bloc);

      bloc.emit(
        const CreateEditPlanReady(
          planId: 'p1',
          planName: 'Test Plan',
          exercises: [],
          isDirty: true,
        ),
      );
      await tester.pump();
      await tester.pump();

      await tester.tap(find.byIcon(Icons.chevron_left));
      await tester.pump();

      expect(find.text(l10n.discardChangesTitle), findsOneWidget);
      expect(find.text(l10n.keepEditingButton), findsOneWidget);
      expect(find.text(l10n.discardButton), findsOneWidget);
      unawaited(bloc.close());
    });

    testWidgets('"Keep Editing" dismisses dialog, form remains', (
      tester,
    ) async {
      final bloc = _bloc();
      await _pumpCreate(tester, bloc);

      bloc.emit(
        const CreateEditPlanReady(
          planId: 'p1',
          planName: 'Test Plan',
          exercises: [],
          isDirty: true,
        ),
      );
      await tester.pump();
      await tester.pump();

      await tester.tap(find.byIcon(Icons.chevron_left));
      await tester.pump();
      expect(find.byType(DiscardDialog), findsOneWidget);

      await tester.tap(find.text(l10n.keepEditingButton));
      await tester.pumpAndSettle();

      expect(find.byType(DiscardDialog), findsNothing);
      // Screen still visible
      expect(find.text(l10n.createPlanTitle), findsOneWidget);
      unawaited(bloc.close());
    });

    testWidgets('"Discard" closes the dialog and leaves the screen once', (
      tester,
    ) async {
      final bloc = _bloc();
      await _pumpCreate(tester, bloc);

      bloc.emit(
        const CreateEditPlanReady(
          planId: 'p1',
          planName: 'Test Plan',
          exercises: [],
          isDirty: true,
        ),
      );
      await tester.pump();
      await tester.pump();

      await tester.tap(find.byIcon(Icons.chevron_left));
      await tester.pump();
      await tester.tap(find.text(l10n.discardButton));
      await tester.pumpAndSettle();

      expect(find.byType(DiscardDialog), findsNothing);
      expect(find.text(l10n.createPlanTitle), findsNothing);
      expect(find.text('Plans'), findsOneWidget);
      unawaited(bloc.close());
    });

    testWidgets('saving state: back tap is swallowed (no dialog, no pop)', (
      tester,
    ) async {
      final bloc = _bloc();
      await _pumpCreate(tester, bloc);

      final ready = _readyWithExercises([], planName: 'Push');
      bloc.emit(CreateEditPlanSaving(readyState: ready));
      await tester.pump();
      await tester.pump();

      await tester.tap(find.byIcon(Icons.chevron_left));
      await tester.pump();

      // Dialog must not appear and screen must still show Saving (spinner)
      expect(find.byType(DiscardDialog), findsNothing);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      unawaited(bloc.close());
    });
  });

  // -------------------------------------------------------------------------
  // T046 — US7: Save failure and retry
  // -------------------------------------------------------------------------

  group('T046 — US7: Save failure and retry', () {
    testWidgets('SaveFailure state shows SaveFailureBanner', (tester) async {
      final bloc = _bloc();
      await _pumpCreate(tester, bloc);

      final ready = _readyWithExercises([], planName: 'Push');
      bloc.emit(CreateEditPlanSaveFailure(readyState: ready));
      await tester.pump();
      await tester.pump();

      expect(find.byType(SaveFailureBanner), findsOneWidget);
      unawaited(bloc.close());
    });

    testWidgets('SaveFailureBanner shows the error message', (tester) async {
      final bloc = _bloc();
      await _pumpCreate(tester, bloc);

      final ready = _readyWithExercises([], planName: 'Push');
      bloc.emit(CreateEditPlanSaveFailure(readyState: ready));
      await tester.pump();
      await tester.pump();

      expect(find.text(l10n.savePlanFailureMessage), findsOneWidget);
      unawaited(bloc.close());
    });

    testWidgets('Retry button visible in SaveFailureBanner', (tester) async {
      final bloc = _bloc();
      await _pumpCreate(tester, bloc);

      final ready = _readyWithExercises([], planName: 'Push');
      bloc.emit(CreateEditPlanSaveFailure(readyState: ready));
      await tester.pump();
      await tester.pump();

      expect(find.text(l10n.retryButton), findsOneWidget);
      unawaited(bloc.close());
    });

    testWidgets('form is interactive (not dimmed) in SaveFailure state', (
      tester,
    ) async {
      final bloc = _bloc();
      await _pumpCreate(tester, bloc);

      final ready = _readyWithExercises([_weightedEntry()], planName: 'Push');
      bloc.emit(CreateEditPlanSaveFailure(readyState: ready));
      await tester.pump();
      await tester.pump();

      // No full-opacity Opacity wrapping the form content (isSaving is false)
      final dimmingOpacity = tester
          .widgetList<Opacity>(find.byType(Opacity))
          .where((o) => o.opacity < 1.0)
          .toList();
      expect(dimmingOpacity, isEmpty);
      unawaited(bloc.close());
    });

    testWidgets('tapping Retry in banner dispatches RetrySaveRequested', (
      tester,
    ) async {
      final successRepo = _FakeRepo(saveResult: Right(_filledDetail()));
      final bloc = CreateEditWorkoutPlanBloc(
        getWorkoutPlanById: GetWorkoutPlanByIdUseCase(successRepo),
        saveWorkoutPlan: SaveWorkoutPlanUseCase(
          repository: successRepo,
          exerciseRepository: const FakeExerciseRepository(_catalogue),
        ),
      );

      await _pumpCreate(tester, bloc);

      final ready = _readyWithExercises(
        [_weightedEntry()],
        planName: 'Push',
        isDirty: true,
      );
      bloc.emit(CreateEditPlanSaveFailure(readyState: ready));
      await tester.pump();
      await tester.pump();

      await tester.tap(find.text(l10n.retryButton));
      await tester.pump(); // processes RetrySaveRequested → SaveRequested
      await tester.pump(); // processes save + emits Saved

      // After successful retry, navigated away from the screen
      expect(find.text('detail:plan-1'), findsOneWidget);
      unawaited(bloc.close());
    });
  });

  group('Save rejected by validation', () {
    PlanExerciseFormEntry emptyEntry() => const PlanExerciseFormEntry(
      exerciseId: 'e-w',
      exerciseName: 'Bench Press',
      type: ExerciseType.weighted,
    );

    CreateEditPlanReady ready(List<PlanExerciseFormEntry> exercises) =>
        CreateEditPlanReady(
          planId: 'p1',
          planName: 'Push',
          exercises: exercises,
          isDirty: true,
        );

    testWidgets('empty fields show one full message in the card, not under '
        'each small box', (tester) async {
      final bloc = _bloc();
      await _pumpCreate(tester, bloc);
      bloc.emit(ready([emptyEntry()]));
      await tester.pump();

      await tester.tap(find.text('Save Plan'));
      await tester.pumpAndSettle();

      expect(find.text('Fill in the highlighted fields'), findsOneWidget);
      expect(find.textContaining('Enter a whole number'), findsNothing);
      bloc.close();
    });

    testWidgets('scrolls to the first invalid exercise when it is off screen', (
      tester,
    ) async {
      final bloc = _bloc();
      await _pumpCreate(tester, bloc);
      bloc.emit(
        ready([for (var i = 0; i < 6; i++) _weightedEntry(), emptyEntry()]),
      );
      await tester.pump();
      final screenHeight =
          tester.view.physicalSize.height / tester.view.devicePixelRatio;

      await tester.tap(find.text('Save Plan'));
      await tester.pumpAndSettle();

      final message = find.text('Fill in the highlighted fields');
      expect(message, findsOneWidget);
      expect(tester.getRect(message).bottom, lessThan(screenHeight));
      bloc.close();
    });

    testWidgets('scrolls back to the plan name when only the name is wrong', (
      tester,
    ) async {
      final bloc = _bloc();
      await _pumpCreate(tester, bloc);
      bloc.emit(
        CreateEditPlanReady(
          planId: 'p1',
          planName: '',
          exercises: [for (var i = 0; i < 7; i++) _weightedEntry()],
          isDirty: true,
        ),
      );
      await tester.pumpAndSettle();
      final scrollable = tester.state<ScrollableState>(
        find
            .descendant(
              of: find.byType(SingleChildScrollView),
              matching: find.byType(Scrollable),
            )
            .first,
      );
      scrollable.position.jumpTo(scrollable.position.maxScrollExtent);
      await tester.pumpAndSettle();

      final nameField = find.byType(PlanNameField);
      expect(tester.getRect(nameField).bottom, lessThan(kToolbarHeight));

      await tester.tap(find.text('Save Plan'));
      await tester.pumpAndSettle();

      expect(find.text('Plan name is required'), findsOneWidget);
      expect(
        tester.getRect(nameField).top,
        greaterThanOrEqualTo(kToolbarHeight),
      );
      bloc.close();
    });
  });
}
