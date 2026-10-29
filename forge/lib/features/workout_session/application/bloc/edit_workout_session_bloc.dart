import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:forge/core/logger/app_logger.dart';
import 'package:forge/features/workout_session/application/bloc/edit_workout_session_event.dart';
import 'package:forge/features/workout_session/application/bloc/edit_workout_session_state.dart';
import 'package:forge/features/workout_session/application/models/edit_exercise_entry.dart';
import 'package:forge/features/workout_session/application/models/edit_set_entry.dart';
import 'package:forge/features/workout_session/application/models/edit_set_mapping.dart';
import 'package:forge/features/workout_session/application/use_cases/get_workout_history_detail_use_case.dart';
import 'package:forge/features/workout_session/domain/entities/session_exercise.dart';
import 'package:forge/features/workout_session/domain/entities/workout_session.dart';
import 'package:forge/features/workout_session/domain/usecases/update_workout_session_usecase.dart';

class EditWorkoutSessionBloc
    extends Bloc<EditWorkoutSessionEvent, EditWorkoutSessionState> {
  EditWorkoutSessionBloc({
    required this._getDetail,
    required this._updateSession,
  }) : super(const EditWorkoutSessionLoading()) {
    on<EditWorkoutSessionLoaded>(_onLoaded);
    on<EditWorkoutSessionFieldChanged>(_onFieldChanged);
    on<EditWorkoutSessionSkipToggled>(_onSkipToggled);
    on<EditWorkoutSessionSaveRequested>(_onSaveRequested);
  }

  final GetWorkoutHistoryDetailUseCase _getDetail;
  final UpdateWorkoutSessionUseCase _updateSession;
  WorkoutSession? _original;

  Future<void> _onLoaded(
    EditWorkoutSessionLoaded event,
    Emitter<EditWorkoutSessionState> emit,
  ) async {
    emit(const EditWorkoutSessionLoading());
    final result = await _getDetail(event.sessionId);
    result.fold(
      (failure) {
        AppLogger.error('Failed to load workout for editing', failure);
        emit(const EditWorkoutSessionLoadError());
      },
      (session) {
        _original = session;
        emit(
          EditWorkoutSessionReady(
            exercises: [
              for (final exercise in session.sessionExercises)
                _toEntry(exercise),
            ],
          ),
        );
      },
    );
  }

  EditExerciseEntry _toEntry(SessionExercise exercise) {
    return EditExerciseEntry(
      exerciseId: exercise.exerciseId,
      exerciseName: exercise.exerciseName,
      type: exercise.type,
      sets: [
        for (final set in exercise.actualSets) EditSetEntry.fromActualSet(set),
      ],
    );
  }

  void _onFieldChanged(
    EditWorkoutSessionFieldChanged event,
    Emitter<EditWorkoutSessionState> emit,
  ) {
    _updateSet(emit, event.exerciseIndex, event.setIndex, (entry) {
      final edited = entry.withText(event.field, event.value);
      final invalid = {...edited.invalidFields}..remove(event.field);
      if (!edited.skipped && !isFieldValid(event.field, event.value)) {
        invalid.add(event.field);
      }
      return edited.copyWith(invalidFields: invalid);
    });
  }

  /// Skipping hides errors; un-skipping re-checks the fields on save.
  void _onSkipToggled(
    EditWorkoutSessionSkipToggled event,
    Emitter<EditWorkoutSessionState> emit,
  ) {
    _updateSet(
      emit,
      event.exerciseIndex,
      event.setIndex,
      (entry) => entry.copyWith(skipped: event.skipped, invalidFields: {}),
    );
  }

  /// The form entries while the form accepts edits, otherwise null.
  List<EditExerciseEntry>? _editableExercises() {
    return switch (state) {
      EditWorkoutSessionReady(:final exercises) ||
      EditWorkoutSessionSaveFailure(:final exercises) => exercises,
      _ => null,
    };
  }

  void _updateSet(
    Emitter<EditWorkoutSessionState> emit,
    int exerciseIndex,
    int setIndex,
    EditSetEntry Function(EditSetEntry entry) update,
  ) {
    final exercises = [...?_editableExercises()];
    if (exercises.isEmpty) return;
    final sets = [...exercises[exerciseIndex].sets];
    sets[setIndex] = update(sets[setIndex]);
    exercises[exerciseIndex] = exercises[exerciseIndex].withSets(sets);
    emit(EditWorkoutSessionReady(exercises: exercises));
  }

  Future<void> _onSaveRequested(
    EditWorkoutSessionSaveRequested event,
    Emitter<EditWorkoutSessionState> emit,
  ) async {
    final original = _original;
    final editable = _editableExercises();
    if (original == null || editable == null) return;
    final validated = _validate(editable);
    if (!validated.every(_hasNoInvalidFields)) {
      emit(EditWorkoutSessionReady(exercises: validated));
      return;
    }
    if (!validated.any(_hasLoggedSet)) {
      emit(EditWorkoutSessionReady(exercises: validated, hasNoValidSet: true));
      return;
    }
    emit(EditWorkoutSessionSaving(exercises: validated));
    final result = await _updateSession(_toSession(original, validated));
    result.fold((failure) {
      AppLogger.error('Failed to update workout session', failure);
      emit(EditWorkoutSessionSaveFailure(exercises: validated));
    }, (_) => emit(const EditWorkoutSessionSaved()));
  }

  List<EditExerciseEntry> _validate(List<EditExerciseEntry> exercises) {
    return [
      for (final exercise in exercises)
        exercise.withSets([
          for (final set in exercise.sets)
            set.copyWith(invalidFields: invalidFieldsOf(set, exercise.type)),
        ]),
    ];
  }

  bool _hasNoInvalidFields(EditExerciseEntry exercise) =>
      exercise.sets.every((set) => set.invalidFields.isEmpty);

  bool _hasLoggedSet(EditExerciseEntry exercise) =>
      exercise.sets.any((set) => isEntryLogged(set, exercise.type));

  WorkoutSession _toSession(
    WorkoutSession original,
    List<EditExerciseEntry> exercises,
  ) {
    return WorkoutSession(
      sessionId: original.sessionId,
      planId: original.planId,
      planName: original.planName,
      completedAt: original.completedAt,
      startedAt: original.startedAt,
      sessionDurationSec: original.sessionDurationSec,
      sessionExercises: [
        for (final exercise in exercises)
          SessionExercise(
            exerciseId: exercise.exerciseId,
            exerciseName: exercise.exerciseName,
            type: exercise.type,
            actualSets: [
              for (final set in exercise.sets) toActualSet(set, exercise.type),
            ],
          ),
      ],
    );
  }
}
