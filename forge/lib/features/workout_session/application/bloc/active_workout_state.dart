import 'package:equatable/equatable.dart';
import 'package:forge/features/workout_plan/workout_plan.dart';
import 'package:forge/features/workout_session/domain/entities/workout_session.dart';

enum SetStatus { pending, logged, skipped }

/// Why a set's input was rejected; the UI turns this into localized text.
enum ActiveWorkoutFieldError {
  repsNotPositive,
  weightInvalid,
  durationNotPositive,
}

sealed class ActiveWorkoutState extends Equatable {
  const ActiveWorkoutState();
}

final class ActiveWorkoutInitial extends ActiveWorkoutState {
  const ActiveWorkoutInitial();

  @override
  List<Object?> get props => [];
}

final class ActiveWorkoutRunning extends ActiveWorkoutState {
  const ActiveWorkoutRunning({
    required this.currentExercise,
    required this.exerciseIndex,
    required this.exerciseCount,
    required this.currentSetIndex,
    required this.setStatuses,
    this.planName = '',
    this.repError,
    this.weightError,
    this.durationError,
    this.isPaused = false,
    this.navigateToPostWorkout = false,
    this.navigateToCancel = false,
    this.navigateToRestTimer = false,
    this.restPeriodSec = 0,
    this.completedSession,
  });

  final PlanExercise currentExercise;
  final int exerciseIndex;
  final int exerciseCount;
  final int currentSetIndex;
  final List<SetStatus> setStatuses;
  final String planName;
  final ActiveWorkoutFieldError? repError;
  final ActiveWorkoutFieldError? weightError;
  final ActiveWorkoutFieldError? durationError;
  final bool isPaused;
  final bool navigateToPostWorkout;
  final bool navigateToCancel;
  final bool navigateToRestTimer;
  final int restPeriodSec;
  final WorkoutSession? completedSession;

  @override
  List<Object?> get props => [
    currentExercise,
    exerciseIndex,
    exerciseCount,
    currentSetIndex,
    setStatuses,
    planName,
    repError,
    weightError,
    durationError,
    isPaused,
    navigateToPostWorkout,
    navigateToCancel,
    navigateToRestTimer,
    restPeriodSec,
    completedSession,
  ];

  ActiveWorkoutRunning copyWith({
    PlanExercise? currentExercise,
    int? exerciseIndex,
    int? exerciseCount,
    int? currentSetIndex,
    List<SetStatus>? setStatuses,
    ActiveWorkoutFieldError? repError,
    ActiveWorkoutFieldError? weightError,
    ActiveWorkoutFieldError? durationError,
    bool? isPaused,
    bool? navigateToPostWorkout,
    bool? navigateToCancel,
    bool? navigateToRestTimer,
    int? restPeriodSec,
    WorkoutSession? completedSession,
    bool clearCompletedSession = false,
    bool clearRepError = false,
    bool clearWeightError = false,
    bool clearDurationError = false,
  }) {
    return ActiveWorkoutRunning(
      currentExercise: currentExercise ?? this.currentExercise,
      exerciseIndex: exerciseIndex ?? this.exerciseIndex,
      exerciseCount: exerciseCount ?? this.exerciseCount,
      currentSetIndex: currentSetIndex ?? this.currentSetIndex,
      setStatuses: setStatuses ?? this.setStatuses,
      planName: planName,
      repError: clearRepError ? null : (repError ?? this.repError),
      weightError: clearWeightError ? null : (weightError ?? this.weightError),
      durationError: clearDurationError
          ? null
          : (durationError ?? this.durationError),
      isPaused: isPaused ?? this.isPaused,
      navigateToPostWorkout:
          navigateToPostWorkout ?? this.navigateToPostWorkout,
      navigateToCancel: navigateToCancel ?? this.navigateToCancel,
      navigateToRestTimer: navigateToRestTimer ?? this.navigateToRestTimer,
      restPeriodSec: restPeriodSec ?? this.restPeriodSec,
      completedSession: clearCompletedSession
          ? null
          : (completedSession ?? this.completedSession),
    );
  }
}
