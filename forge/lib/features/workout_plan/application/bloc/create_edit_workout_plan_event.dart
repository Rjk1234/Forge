import 'package:equatable/equatable.dart';
import 'package:forge/features/exercise/domain/entities/exercise.dart';

sealed class CreateEditWorkoutPlanEvent extends Equatable {
  const CreateEditWorkoutPlanEvent();
}

/// Dispatched once when the screen mounts.
/// [planId] is null for create mode, non-null for edit mode.
final class CreateEditPlanInitialized extends CreateEditWorkoutPlanEvent {
  const CreateEditPlanInitialized({this.planId});

  final String? planId;

  @override
  List<Object?> get props => [planId];
}

final class PlanNameChanged extends CreateEditWorkoutPlanEvent {
  const PlanNameChanged(this.name);

  final String name;

  @override
  List<Object> get props => [name];
}

/// Dispatched when the user picks an exercise from the catalogue screen.
final class ExerciseAdded extends CreateEditWorkoutPlanEvent {
  const ExerciseAdded(this.exercise);

  final Exercise exercise;

  @override
  List<Object> get props => [exercise];
}

/// Dispatched when the user taps the Remove button on an exercise card.
final class ExerciseRemoved extends CreateEditWorkoutPlanEvent {
  const ExerciseRemoved(this.index);

  final int index;

  @override
  List<Object> get props => [index];
}

/// Dispatched on any numeric field change in an exercise card.
final class ExerciseFieldChanged extends CreateEditWorkoutPlanEvent {
  const ExerciseFieldChanged({
    required this.index,
    required this.field,
    required this.value,
  });

  final int index;
  final ExerciseField field;
  final String value;

  @override
  List<Object> get props => [index, field, value];
}

enum ExerciseField { sets, repsOrDuration, weight, rest }

final class SaveRequested extends CreateEditWorkoutPlanEvent {
  const SaveRequested();

  @override
  List<Object> get props => [];
}

final class RetrySaveRequested extends CreateEditWorkoutPlanEvent {
  const RetrySaveRequested();

  @override
  List<Object> get props => [];
}
