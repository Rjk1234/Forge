import 'package:equatable/equatable.dart';
import 'package:forge/features/workout_session/application/models/edit_exercise_entry.dart';

sealed class EditWorkoutSessionState extends Equatable {
  const EditWorkoutSessionState();

  @override
  List<Object?> get props => [];
}

final class EditWorkoutSessionLoading extends EditWorkoutSessionState {
  const EditWorkoutSessionLoading();
}

final class EditWorkoutSessionLoadError extends EditWorkoutSessionState {
  const EditWorkoutSessionLoadError();
}

final class EditWorkoutSessionSaved extends EditWorkoutSessionState {
  const EditWorkoutSessionSaved();
}

/// A state that still shows the form.
sealed class EditWorkoutSessionEditable extends EditWorkoutSessionState {
  const EditWorkoutSessionEditable({required this.exercises});

  final List<EditExerciseEntry> exercises;

  @override
  List<Object?> get props => [exercises];
}

final class EditWorkoutSessionReady extends EditWorkoutSessionEditable {
  const EditWorkoutSessionReady({
    required super.exercises,
    this.hasNoValidSet = false,
  });

  /// True when a save was attempted with every set skipped or incomplete.
  final bool hasNoValidSet;

  @override
  List<Object?> get props => [exercises, hasNoValidSet];
}

final class EditWorkoutSessionSaving extends EditWorkoutSessionEditable {
  const EditWorkoutSessionSaving({required super.exercises});
}

final class EditWorkoutSessionSaveFailure extends EditWorkoutSessionEditable {
  const EditWorkoutSessionSaveFailure({required super.exercises});
}
