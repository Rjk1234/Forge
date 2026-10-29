import 'package:equatable/equatable.dart';
import 'package:forge/features/workout_plan/application/bloc/plan_field_error.dart';
import 'package:forge/core/enums/exercise_type.dart';

/// In-memory form value object representing a single exercise entry in the
/// create/edit form. Lives in Application layer only — never persisted directly.
///
/// Raw string values are stored as typed by the user; conversion to typed
/// domain values happens at save time in the Bloc.
class PlanExerciseFormEntry extends Equatable {
  const PlanExerciseFormEntry({
    required this.exerciseId,
    required this.exerciseName,
    required this.type,
    this.sets = '',
    this.repsOrDuration = '',
    this.weight = '',
    this.rest = '',
    this.setsError,
    this.repsOrDurationError,
    this.weightError,
    this.restError,
  });

  final String exerciseId;
  final String exerciseName;
  final ExerciseType type;

  final String sets;
  final String repsOrDuration;
  final String weight;
  final String rest;

  final PlanFieldError? setsError;
  final PlanFieldError? repsOrDurationError;
  final PlanFieldError? weightError;
  final PlanFieldError? restError;

  bool get hasErrors =>
      setsError != null ||
      repsOrDurationError != null ||
      weightError != null ||
      restError != null;

  PlanExerciseFormEntry copyWith({
    String? sets,
    String? repsOrDuration,
    String? weight,
    String? rest,
    Object? setsError = _sentinel,
    Object? repsOrDurationError = _sentinel,
    Object? weightError = _sentinel,
    Object? restError = _sentinel,
  }) {
    return PlanExerciseFormEntry(
      exerciseId: exerciseId,
      exerciseName: exerciseName,
      type: type,
      sets: sets ?? this.sets,
      repsOrDuration: repsOrDuration ?? this.repsOrDuration,
      weight: weight ?? this.weight,
      rest: rest ?? this.rest,
      setsError: setsError == _sentinel
          ? this.setsError
          : setsError as PlanFieldError?,
      repsOrDurationError: repsOrDurationError == _sentinel
          ? this.repsOrDurationError
          : repsOrDurationError as PlanFieldError?,
      weightError: weightError == _sentinel
          ? this.weightError
          : weightError as PlanFieldError?,
      restError: restError == _sentinel
          ? this.restError
          : restError as PlanFieldError?,
    );
  }

  @override
  List<Object?> get props => [
    exerciseId,
    exerciseName,
    type,
    sets,
    repsOrDuration,
    weight,
    rest,
    setsError,
    repsOrDurationError,
    weightError,
    restError,
  ];
}

// Sentinel to distinguish "not provided" from "explicitly null" in copyWith.
const _sentinel = Object();
