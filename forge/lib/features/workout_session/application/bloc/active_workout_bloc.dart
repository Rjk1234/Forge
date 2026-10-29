import 'dart:math' as math;

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:forge/core/enums/exercise_type.dart';
import 'package:forge/core/validation/workout_value_rules.dart';
import 'package:forge/features/workout_plan/workout_plan.dart';
import 'package:forge/features/workout_session/application/bloc/active_workout_event.dart';
import 'package:forge/features/workout_session/application/bloc/active_workout_state.dart';
import 'package:forge/features/workout_session/domain/entities/actual_set.dart';
import 'package:forge/features/workout_session/domain/entities/session_exercise.dart';
import 'package:forge/features/workout_session/domain/entities/workout_session.dart';
import 'package:uuid/uuid.dart';

class ActiveWorkoutBloc extends Bloc<ActiveWorkoutEvent, ActiveWorkoutState> {
  ActiveWorkoutBloc() : super(const ActiveWorkoutInitial()) {
    on<ActiveWorkoutStarted>(_onStarted);
    on<ActiveWorkoutCompleteSetRequested>(_onCompleteSet);
    on<ActiveWorkoutSkipSetRequested>(_onSkipSet);
    on<ActiveWorkoutPauseRequested>(_onPause);
    on<ActiveWorkoutResumeRequested>(_onResume);
    on<ActiveWorkoutFieldChanged>(_onFieldChanged);
    on<ActiveWorkoutPostWorkoutNavigated>(_onPostWorkoutNavigated);
    on<ActiveWorkoutRestTimerNavigated>(_onRestTimerNavigated);
    on<ActiveWorkoutCancelRequested>(_onCancelRequested);
    on<ActiveWorkoutCancelNavigated>(_onCancelNavigated);
  }

  late WorkoutPlanDetail _plan;
  late DateTime _startedAt;

  /// Monotonic clock for active workout time; paused time is excluded and a
  /// device clock change cannot make the duration negative.
  final Stopwatch _activeTime = Stopwatch();
  late List<List<_SetEntry>> _loggedSets;
  int _exerciseIdx = 0;
  int _setIdx = 0;

  void _onStarted(
    ActiveWorkoutStarted event,
    Emitter<ActiveWorkoutState> emit,
  ) {
    _plan = event.plan;
    _startedAt = DateTime.now();
    _activeTime
      ..reset()
      ..start();
    _exerciseIdx = 0;
    _setIdx = 0;
    _loggedSets = event.plan.exercises.map((exercise) {
      return List.generate(
        exercise.targetSets,
        (_) => _SetEntry(
          targetReps: exercise.targetRepetitions,
          targetWeight: exercise.targetWeight,
          targetDurationSec: exercise.targetDurationSec,
        ),
      );
    }).toList();
    emit(_buildRunning());
  }

  void _onCompleteSet(
    ActiveWorkoutCompleteSetRequested event,
    Emitter<ActiveWorkoutState> emit,
  ) {
    final running = state as ActiveWorkoutRunning;
    final exercise = _plan.exercises[_exerciseIdx];
    final errors = _validate(
      exercise.type,
      event.reps,
      event.weight,
      event.durationSec,
    );
    if (errors.hasError) {
      emit(
        running.copyWith(
          repError: errors.repError,
          weightError: errors.weightError,
          durationError: errors.durationError,
        ),
      );
      return;
    }
    final entry = _loggedSets[_exerciseIdx][_setIdx];
    entry.status = SetStatus.logged;
    entry.actualReps = event.reps;
    entry.actualWeight = event.weight;
    entry.actualDurationSec = event.durationSec;

    if (_isLastOfLast) {
      if (_loggedCount > 0) {
        _prepareFinish(emit);
      } else {
        emit(running.copyWith(navigateToCancel: true));
      }
    } else {
      _advance();
      final restSec = exercise.restPeriodSec;
      emit(
        restSec > 0
            ? _buildRunning().copyWith(
                navigateToRestTimer: true,
                restPeriodSec: restSec,
              )
            : _buildRunning(),
      );
    }
  }

  void _onSkipSet(
    ActiveWorkoutSkipSetRequested event,
    Emitter<ActiveWorkoutState> emit,
  ) {
    final running = state as ActiveWorkoutRunning;
    _loggedSets[_exerciseIdx][_setIdx].status = SetStatus.skipped;

    if (_isLastOfLast) {
      if (_loggedCount > 0) {
        _prepareFinish(emit);
      } else {
        emit(running.copyWith(navigateToCancel: true));
      }
    } else {
      _advance();
      emit(_buildRunning());
    }
  }

  void _onPause(
    ActiveWorkoutPauseRequested event,
    Emitter<ActiveWorkoutState> emit,
  ) {
    final running = state as ActiveWorkoutRunning;
    _activeTime.stop();
    emit(running.copyWith(isPaused: true));
  }

  void _onResume(
    ActiveWorkoutResumeRequested event,
    Emitter<ActiveWorkoutState> emit,
  ) {
    final running = state as ActiveWorkoutRunning;
    _activeTime.start();
    emit(running.copyWith(isPaused: false));
  }

  void _onFieldChanged(
    ActiveWorkoutFieldChanged event,
    Emitter<ActiveWorkoutState> emit,
  ) {
    final running = state as ActiveWorkoutRunning;
    switch (event.field) {
      case ActiveWorkoutField.reps:
        if (running.repError == null) return;
        emit(running.copyWith(clearRepError: true));
      case ActiveWorkoutField.weight:
        if (running.weightError == null) return;
        emit(running.copyWith(clearWeightError: true));
      case ActiveWorkoutField.duration:
        if (running.durationError == null) return;
        emit(running.copyWith(clearDurationError: true));
    }
  }

  void _onRestTimerNavigated(
    ActiveWorkoutRestTimerNavigated event,
    Emitter<ActiveWorkoutState> emit,
  ) {
    final current = state;
    if (current is! ActiveWorkoutRunning) return;
    emit(current.copyWith(navigateToRestTimer: false, restPeriodSec: 0));
  }

  void _onCancelRequested(
    ActiveWorkoutCancelRequested event,
    Emitter<ActiveWorkoutState> emit,
  ) {
    final current = state;
    if (current is! ActiveWorkoutRunning) return;
    emit(current.copyWith(navigateToCancel: true));
  }

  void _onCancelNavigated(
    ActiveWorkoutCancelNavigated event,
    Emitter<ActiveWorkoutState> emit,
  ) {
    final current = state;
    if (current is! ActiveWorkoutRunning) return;
    emit(current.copyWith(navigateToCancel: false));
  }

  void _onPostWorkoutNavigated(
    ActiveWorkoutPostWorkoutNavigated event,
    Emitter<ActiveWorkoutState> emit,
  ) {
    final current = state;
    if (current is! ActiveWorkoutRunning) return;
    emit(
      current.copyWith(
        navigateToPostWorkout: false,
        clearCompletedSession: true,
      ),
    );
  }

  void _prepareFinish(Emitter<ActiveWorkoutState> emit) {
    emit(
      _buildRunning().copyWith(
        navigateToPostWorkout: true,
        completedSession: _buildSession(),
      ),
    );
  }

  WorkoutSession _buildSession() {
    final now = DateTime.now();
    final exercises = <SessionExercise>[];
    for (var i = 0; i < _plan.exercises.length; i++) {
      final exercise = _plan.exercises[i];
      final actualSets = _loggedSets[i]
          .map((entry) {
            return ActualSet(
              repetitions: entry.actualReps,
              weight: entry.actualWeight,
              durationSec: entry.actualDurationSec,
              skipped: entry.status == SetStatus.skipped,
            );
          })
          .toList(growable: false);
      exercises.add(
        SessionExercise(
          exerciseId: exercise.exerciseId,
          exerciseName: exercise.exerciseName,
          type: exercise.type,
          actualSets: actualSets,
        ),
      );
    }
    return WorkoutSession(
      sessionId: const Uuid().v4(),
      planId: _plan.id,
      planName: _plan.name,
      completedAt: now.isBefore(_startedAt) ? _startedAt : now,
      startedAt: _startedAt,
      sessionDurationSec: math.min(
        _activeTime.elapsed.inSeconds,
        WorkoutLimits.maxSessionDurationSec,
      ),
      sessionExercises: exercises,
    );
  }

  ActiveWorkoutRunning _buildRunning() {
    final exercise = _plan.exercises[_exerciseIdx];
    final sets = _loggedSets[_exerciseIdx];
    return ActiveWorkoutRunning(
      currentExercise: exercise,
      exerciseIndex: _exerciseIdx,
      exerciseCount: _plan.exercises.length,
      currentSetIndex: _setIdx,
      planName: _plan.name,
      setStatuses: sets.map((e) => e.status).toList(growable: false),
    );
  }

  bool get _isLastOfLast =>
      _exerciseIdx == _plan.exercises.length - 1 &&
      _setIdx == _loggedSets[_exerciseIdx].length - 1;

  int get _loggedCount => _loggedSets.fold(
    0,
    (total, sets) =>
        total + sets.where((e) => e.status == SetStatus.logged).length,
  );

  void _advance() {
    final setsInExercise = _loggedSets[_exerciseIdx].length;
    if (_setIdx < setsInExercise - 1) {
      _setIdx++;
    } else {
      _exerciseIdx++;
      _setIdx = 0;
    }
  }

  _ValidationResult _validate(
    ExerciseType type,
    int? reps,
    double? weight,
    int? durationSec,
  ) {
    ActiveWorkoutFieldError? repError;
    ActiveWorkoutFieldError? weightError;
    ActiveWorkoutFieldError? durationError;

    switch (type) {
      case ExerciseType.weighted:
        if (!WorkoutValueRules.isValidRepetitions(reps)) {
          repError = ActiveWorkoutFieldError.repsNotPositive;
        }
        if (!WorkoutValueRules.isValidWeight(weight)) {
          weightError = ActiveWorkoutFieldError.weightInvalid;
        }
      case ExerciseType.bodyweight:
        if (!WorkoutValueRules.isValidRepetitions(reps)) {
          repError = ActiveWorkoutFieldError.repsNotPositive;
        }
      case ExerciseType.timeBased:
        if (!WorkoutValueRules.isValidDurationSec(durationSec)) {
          durationError = ActiveWorkoutFieldError.durationNotPositive;
        }
    }

    return _ValidationResult(
      repError: repError,
      weightError: weightError,
      durationError: durationError,
    );
  }
}

class _SetEntry {
  _SetEntry({
    required this.targetReps,
    required this.targetWeight,
    required this.targetDurationSec,
  });

  final int? targetReps;
  final double? targetWeight;
  final int? targetDurationSec;
  SetStatus status = SetStatus.pending;
  int? actualReps;
  double? actualWeight;
  int? actualDurationSec;
}

class _ValidationResult {
  const _ValidationResult({
    this.repError,
    this.weightError,
    this.durationError,
  });

  final ActiveWorkoutFieldError? repError;
  final ActiveWorkoutFieldError? weightError;
  final ActiveWorkoutFieldError? durationError;

  bool get hasError =>
      repError != null || weightError != null || durationError != null;
}
