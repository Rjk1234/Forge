import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:forge/core/enums/exercise_type.dart';
import 'package:forge/core/validation/workout_value_rules.dart';
import 'package:forge/features/workout_plan/application/bloc/create_edit_workout_plan_event.dart';
import 'package:forge/features/workout_plan/application/bloc/plan_field_error.dart';
import 'package:forge/features/workout_plan/application/bloc/create_edit_workout_plan_state.dart';
import 'package:forge/features/workout_plan/application/bloc/plan_exercise_form_entry.dart';
import 'package:forge/features/workout_plan/domain/entities/plan_exercise.dart';
import 'package:forge/features/workout_plan/domain/entities/workout_plan_detail.dart';
import 'package:forge/features/workout_plan/domain/usecases/get_workout_plan_by_id_usecase.dart';
import 'package:forge/features/workout_plan/domain/usecases/save_workout_plan_usecase.dart';
import 'package:uuid/uuid.dart';

class CreateEditWorkoutPlanBloc
    extends Bloc<CreateEditWorkoutPlanEvent, CreateEditWorkoutPlanState> {
  CreateEditWorkoutPlanBloc({
    required this.getWorkoutPlanById,
    required this.saveWorkoutPlan,
  }) : super(const CreateEditPlanInitial()) {
    on<CreateEditPlanInitialized>(_onInitialized);
    on<PlanNameChanged>(_onPlanNameChanged);
    on<ExerciseAdded>(_onExerciseAdded);
    on<ExerciseRemoved>(_onExerciseRemoved);
    on<ExerciseFieldChanged>(_onExerciseFieldChanged);
    on<SaveRequested>(_onSaveRequested);
    on<RetrySaveRequested>(_onRetrySaveRequested);
  }

  final GetWorkoutPlanByIdUseCase getWorkoutPlanById;
  final SaveWorkoutPlanUseCase saveWorkoutPlan;

  FutureOr<void> _onInitialized(
    CreateEditPlanInitialized event,
    Emitter<CreateEditWorkoutPlanState> emit,
  ) async {
    if (event.planId == null) {
      // Create mode — blank form with a pre-assigned UUID.
      emit(
        CreateEditPlanReady(
          planId: const Uuid().v4(),
          planName: '',
          exercises: const [],
          isDirty: false,
        ),
      );
      return;
    }

    // Edit mode — load existing plan.
    emit(const CreateEditPlanLoading());
    final result = await getWorkoutPlanById(event.planId!);
    result.fold(
      (failure) => emit(const CreateEditPlanLoadError()),
      (detail) => emit(
        CreateEditPlanReady(
          planId: detail.id,
          planName: detail.name,
          exercises: detail.exercises
              .map(_formEntryFromDomain)
              .toList(growable: false),
          isDirty: false,
          createdAt: detail.createdAt,
        ),
      ),
    );
  }

  FutureOr<void> _onPlanNameChanged(
    PlanNameChanged event,
    Emitter<CreateEditWorkoutPlanState> emit,
  ) {
    final ready = _requireReady();
    if (ready != null) {
      emit(
        ready.copyWith(planName: event.name, isDirty: true, nameError: null),
      );
    }
  }

  FutureOr<void> _onExerciseAdded(
    ExerciseAdded event,
    Emitter<CreateEditWorkoutPlanState> emit,
  ) {
    final ready = _requireReady();
    if (ready != null) {
      final entry = PlanExerciseFormEntry(
        exerciseId: event.exercise.id,
        exerciseName: event.exercise.name,
        type: event.exercise.type,
      );
      emit(
        ready.copyWith(
          exercises: [...ready.exercises, entry],
          isDirty: true,
          exercisesError: null,
        ),
      );
    }
  }

  FutureOr<void> _onExerciseRemoved(
    ExerciseRemoved event,
    Emitter<CreateEditWorkoutPlanState> emit,
  ) {
    final ready = _requireReady();
    if (ready != null) {
      final updated = List<PlanExerciseFormEntry>.from(ready.exercises)
        ..removeAt(event.index);
      emit(ready.copyWith(exercises: updated, isDirty: true));
    }
  }

  FutureOr<void> _onExerciseFieldChanged(
    ExerciseFieldChanged event,
    Emitter<CreateEditWorkoutPlanState> emit,
  ) {
    final ready = _requireReady();
    if (ready != null) {
      _applyFieldChange(ready, event, emit);
    }
  }

  void _applyFieldChange(
    CreateEditPlanReady ready,
    ExerciseFieldChanged event,
    Emitter<CreateEditWorkoutPlanState> emit,
  ) {
    final entry = ready.exercises[event.index];
    final updated = switch (event.field) {
      ExerciseField.sets => entry.copyWith(sets: event.value, setsError: null),
      ExerciseField.repsOrDuration => entry.copyWith(
        repsOrDuration: event.value,
        repsOrDurationError: null,
      ),
      ExerciseField.weight => entry.copyWith(
        weight: event.value,
        weightError: null,
      ),
      ExerciseField.rest => entry.copyWith(rest: event.value, restError: null),
    };
    final exercises = List<PlanExerciseFormEntry>.from(ready.exercises)
      ..[event.index] = updated;
    emit(ready.copyWith(exercises: exercises, isDirty: true));
  }

  FutureOr<void> _onSaveRequested(
    SaveRequested event,
    Emitter<CreateEditWorkoutPlanState> emit,
  ) async {
    final ready = _requireReady();
    if (ready == null) return;

    final validated = _validate(ready);
    if (!validated.canSave) {
      emit(validated.copyWith(rejectedSaveCount: ready.rejectedSaveCount + 1));
      return;
    }

    emit(CreateEditPlanSaving(readyState: validated));

    final detail = _buildDetail(validated);
    final result = await saveWorkoutPlan(detail);

    result.fold(
      (failure) => emit(CreateEditPlanSaveFailure(readyState: validated)),
      (saved) => emit(CreateEditPlanSaved(savedPlanId: saved.id)),
    );
  }

  FutureOr<void> _onRetrySaveRequested(
    RetrySaveRequested event,
    Emitter<CreateEditWorkoutPlanState> emit,
  ) async {
    final failure = state;
    if (failure is! CreateEditPlanSaveFailure) return;
    add(const SaveRequested());
  }

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  CreateEditPlanReady? _requireReady() {
    final s = state;
    if (s is CreateEditPlanReady) return s;
    if (s is CreateEditPlanSaveFailure) return s.readyState;
    return null;
  }

  CreateEditPlanReady _validate(CreateEditPlanReady ready) {
    return ready.copyWith(
      exercises: ready.exercises.map(_validateEntry).toList(growable: false),
      nameError: WorkoutValueRules.isValidName(ready.planName)
          ? null
          : PlanFieldError.nameRequired,
      exercisesError: ready.exercises.isEmpty
          ? PlanFieldError.exercisesRequired
          : null,
    );
  }

  PlanExerciseFormEntry _validateEntry(PlanExerciseFormEntry entry) {
    final isWeighted = entry.type == ExerciseType.weighted;
    return entry.copyWith(
      setsError: WorkoutValueRules.isValidSetCount(int.tryParse(entry.sets))
          ? null
          : PlanFieldError.setsInvalid,
      restError: WorkoutValueRules.isValidRestSec(int.tryParse(entry.rest))
          ? null
          : PlanFieldError.restInvalid,
      repsOrDurationError: _repsOrDurationError(entry),
      weightError:
          isWeighted &&
              !WorkoutValueRules.isValidWeight(double.tryParse(entry.weight))
          ? PlanFieldError.weightInvalid
          : null,
    );
  }

  PlanFieldError? _repsOrDurationError(PlanExerciseFormEntry entry) {
    if (entry.type == ExerciseType.timeBased) {
      return _durationError(entry.repsOrDuration);
    }
    return WorkoutValueRules.isValidRepetitions(
          int.tryParse(entry.repsOrDuration),
        )
        ? null
        : PlanFieldError.repsInvalid;
  }

  /// [text] is `mm:ss`; the total must be a valid duration.
  PlanFieldError? _durationError(String text) {
    final parts = text.split(':');
    if (parts.length != 2) return PlanFieldError.durationFormat;
    final minutes = int.tryParse(parts[0]) ?? -1;
    final seconds = int.tryParse(parts[1]) ?? -1;
    final isValid =
        minutes >= 0 &&
        seconds >= 0 &&
        seconds < 60 &&
        WorkoutValueRules.isValidDurationSec(minutes * 60 + seconds);
    return isValid ? null : PlanFieldError.durationInvalid;
  }

  WorkoutPlanDetail _buildDetail(CreateEditPlanReady ready) {
    final exercises = ready.exercises
        .map((entry) {
          final sets = int.parse(entry.sets);
          final rest = int.parse(entry.rest);
          return switch (entry.type) {
            ExerciseType.weighted => PlanExercise(
              exerciseId: entry.exerciseId,
              exerciseName: entry.exerciseName,
              type: entry.type,
              targetSets: sets,
              restPeriodSec: rest,
              targetRepetitions: int.parse(entry.repsOrDuration),
              targetWeight: double.parse(entry.weight),
            ),
            ExerciseType.bodyweight => PlanExercise(
              exerciseId: entry.exerciseId,
              exerciseName: entry.exerciseName,
              type: entry.type,
              targetSets: sets,
              restPeriodSec: rest,
              targetRepetitions: int.parse(entry.repsOrDuration),
            ),
            ExerciseType.timeBased => PlanExercise(
              exerciseId: entry.exerciseId,
              exerciseName: entry.exerciseName,
              type: entry.type,
              targetSets: sets,
              restPeriodSec: rest,
              targetDurationSec: _parseMmSsToSeconds(entry.repsOrDuration),
            ),
          };
        })
        .toList(growable: false);

    return WorkoutPlanDetail(
      id: ready.planId,
      name: ready.planName.trim(),
      exercises: exercises,
      createdAt: ready.createdAt ?? DateTime.now(),
    );
  }

  int _parseMmSsToSeconds(String value) {
    final parts = value.split(':');
    if (parts.length != 2) return 0;
    return (int.tryParse(parts[0]) ?? 0) * 60 + (int.tryParse(parts[1]) ?? 0);
  }

  PlanExerciseFormEntry _formEntryFromDomain(PlanExercise exercise) {
    final String repsOrDuration;
    switch (exercise.type) {
      case ExerciseType.weighted:
      case ExerciseType.bodyweight:
        repsOrDuration = '${exercise.targetRepetitions ?? ''}';
      case ExerciseType.timeBased:
        final total = exercise.targetDurationSec ?? 0;
        final mm = (total ~/ 60).toString().padLeft(2, '0');
        final ss = (total % 60).toString().padLeft(2, '0');
        repsOrDuration = '$mm:$ss';
    }

    return PlanExerciseFormEntry(
      exerciseId: exercise.exerciseId,
      exerciseName: exercise.exerciseName,
      type: exercise.type,
      sets: '${exercise.targetSets}',
      repsOrDuration: repsOrDuration,
      weight: exercise.targetWeight != null ? '${exercise.targetWeight}' : '',
      rest: '${exercise.restPeriodSec}',
    );
  }
}
