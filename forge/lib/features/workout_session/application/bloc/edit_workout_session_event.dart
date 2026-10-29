import 'package:equatable/equatable.dart';
import 'package:forge/features/workout_session/application/models/edit_set_entry.dart';

sealed class EditWorkoutSessionEvent extends Equatable {
  const EditWorkoutSessionEvent();
}

final class EditWorkoutSessionLoaded extends EditWorkoutSessionEvent {
  const EditWorkoutSessionLoaded({required this.sessionId});

  final String sessionId;

  @override
  List<Object?> get props => [sessionId];
}

final class EditWorkoutSessionFieldChanged extends EditWorkoutSessionEvent {
  const EditWorkoutSessionFieldChanged({
    required this.exerciseIndex,
    required this.setIndex,
    required this.field,
    required this.value,
  });

  final int exerciseIndex;
  final int setIndex;
  final EditSetField field;
  final String value;

  @override
  List<Object?> get props => [exerciseIndex, setIndex, field, value];
}

final class EditWorkoutSessionSkipToggled extends EditWorkoutSessionEvent {
  const EditWorkoutSessionSkipToggled({
    required this.exerciseIndex,
    required this.setIndex,
    required this.skipped,
  });

  final int exerciseIndex;
  final int setIndex;
  final bool skipped;

  @override
  List<Object?> get props => [exerciseIndex, setIndex, skipped];
}

final class EditWorkoutSessionSaveRequested extends EditWorkoutSessionEvent {
  const EditWorkoutSessionSaveRequested();

  @override
  List<Object?> get props => [];
}
