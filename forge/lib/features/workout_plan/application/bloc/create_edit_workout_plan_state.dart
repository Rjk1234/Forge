import 'package:equatable/equatable.dart';
import 'package:forge/features/workout_plan/application/bloc/plan_field_error.dart';
import 'package:forge/features/workout_plan/application/bloc/plan_exercise_form_entry.dart';

sealed class CreateEditWorkoutPlanState extends Equatable {
  const CreateEditWorkoutPlanState();
}

final class CreateEditPlanInitial extends CreateEditWorkoutPlanState {
  const CreateEditPlanInitial();

  @override
  List<Object> get props => [];
}

final class CreateEditPlanLoading extends CreateEditWorkoutPlanState {
  const CreateEditPlanLoading();

  @override
  List<Object> get props => [];
}

final class CreateEditPlanReady extends CreateEditWorkoutPlanState {
  const CreateEditPlanReady({
    required this.planId,
    required this.planName,
    required this.exercises,
    required this.isDirty,
    this.nameError,
    this.exercisesError,
    this.createdAt,
    this.rejectedSaveCount = 0,
  });

  /// Non-null even in create mode — generated UUID assigned at init.
  final String planId;
  final String planName;
  final List<PlanExerciseFormEntry> exercises;
  final bool isDirty;
  final PlanFieldError? nameError;
  final PlanFieldError? exercisesError;

  /// Original creation time of a plan being edited; null while creating.
  final DateTime? createdAt;

  /// How many times Save was pressed and rejected by validation. It changes on
  /// every rejection, even when the errors are the same, so the screen can
  /// scroll to the first error each time.
  final int rejectedSaveCount;

  bool get canSave =>
      nameError == null &&
      exercisesError == null &&
      exercises.every((e) => !e.hasErrors);

  CreateEditPlanReady copyWith({
    String? planName,
    List<PlanExerciseFormEntry>? exercises,
    bool? isDirty,
    Object? nameError = _sentinel,
    Object? exercisesError = _sentinel,
    int? rejectedSaveCount,
  }) {
    return CreateEditPlanReady(
      planId: planId,
      planName: planName ?? this.planName,
      exercises: exercises ?? this.exercises,
      isDirty: isDirty ?? this.isDirty,
      nameError: nameError == _sentinel
          ? this.nameError
          : nameError as PlanFieldError?,
      exercisesError: exercisesError == _sentinel
          ? this.exercisesError
          : exercisesError as PlanFieldError?,
      createdAt: createdAt,
      rejectedSaveCount: rejectedSaveCount ?? this.rejectedSaveCount,
    );
  }

  @override
  List<Object?> get props => [
    planId,
    planName,
    exercises,
    isDirty,
    nameError,
    exercisesError,
    createdAt,
    rejectedSaveCount,
  ];
}

final class CreateEditPlanSaving extends CreateEditWorkoutPlanState {
  const CreateEditPlanSaving({required this.readyState});

  final CreateEditPlanReady readyState;

  @override
  List<Object> get props => [readyState];
}

final class CreateEditPlanSaved extends CreateEditWorkoutPlanState {
  const CreateEditPlanSaved({required this.savedPlanId});

  final String savedPlanId;

  @override
  List<Object> get props => [savedPlanId];
}

final class CreateEditPlanLoadError extends CreateEditWorkoutPlanState {
  const CreateEditPlanLoadError();

  @override
  List<Object> get props => [];
}

final class CreateEditPlanSaveFailure extends CreateEditWorkoutPlanState {
  const CreateEditPlanSaveFailure({required this.readyState});

  final CreateEditPlanReady readyState;

  @override
  List<Object> get props => [readyState];
}

const _sentinel = Object();
