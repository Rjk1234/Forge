import 'package:equatable/equatable.dart';
import 'package:forge/features/workout_plan/workout_plan.dart';

enum ActiveWorkoutField { reps, weight, duration }

sealed class ActiveWorkoutEvent extends Equatable {
  const ActiveWorkoutEvent();
}

final class ActiveWorkoutStarted extends ActiveWorkoutEvent {
  const ActiveWorkoutStarted({required this.plan});

  final WorkoutPlanDetail plan;

  @override
  List<Object?> get props => [plan];
}

final class ActiveWorkoutCompleteSetRequested extends ActiveWorkoutEvent {
  const ActiveWorkoutCompleteSetRequested({
    this.reps,
    this.weight,
    this.durationSec,
  });

  final int? reps;
  final double? weight;
  final int? durationSec;

  @override
  List<Object?> get props => [reps, weight, durationSec];
}

final class ActiveWorkoutSkipSetRequested extends ActiveWorkoutEvent {
  const ActiveWorkoutSkipSetRequested();

  @override
  List<Object?> get props => [];
}

final class ActiveWorkoutPauseRequested extends ActiveWorkoutEvent {
  const ActiveWorkoutPauseRequested();

  @override
  List<Object?> get props => [];
}

final class ActiveWorkoutResumeRequested extends ActiveWorkoutEvent {
  const ActiveWorkoutResumeRequested();

  @override
  List<Object?> get props => [];
}

final class ActiveWorkoutFieldChanged extends ActiveWorkoutEvent {
  const ActiveWorkoutFieldChanged({required this.field, required this.value});

  final ActiveWorkoutField field;
  final String value;

  @override
  List<Object?> get props => [field, value];
}

final class ActiveWorkoutRestTimerNavigated extends ActiveWorkoutEvent {
  const ActiveWorkoutRestTimerNavigated();

  @override
  List<Object?> get props => [];
}

final class ActiveWorkoutCancelRequested extends ActiveWorkoutEvent {
  const ActiveWorkoutCancelRequested();

  @override
  List<Object?> get props => [];
}

final class ActiveWorkoutCancelNavigated extends ActiveWorkoutEvent {
  const ActiveWorkoutCancelNavigated();

  @override
  List<Object?> get props => [];
}

final class ActiveWorkoutPostWorkoutNavigated extends ActiveWorkoutEvent {
  const ActiveWorkoutPostWorkoutNavigated();

  @override
  List<Object?> get props => [];
}
