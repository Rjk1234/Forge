import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:forge/core/logger/app_logger.dart';
import 'package:forge/features/progress/application/bloc/progress_event.dart';
import 'package:forge/features/progress/application/bloc/progress_state.dart';
import 'package:forge/features/progress/application/use_cases/get_exercise_progress_data_use_case.dart';

class ProgressBloc extends Bloc<ProgressEvent, ProgressState> {
  ProgressBloc({required this._getProgressData})
    : super(const ProgressInitial()) {
    on<ProgressLoadRequested>(_onLoadRequested);
    on<ProgressExerciseSelected>(_onExerciseSelected);
  }

  final GetExerciseProgressDataUseCase _getProgressData;

  /// A reload asked for while one is running; served right after it.
  bool _reloadPending = false;

  Future<void> _onLoadRequested(
    ProgressLoadRequested event,
    Emitter<ProgressState> emit,
  ) async {
    if (state is ProgressLoading) {
      _reloadPending = true;
      return;
    }
    do {
      _reloadPending = false;
      emit(const ProgressLoading());
      final result = await _getProgressData();
      emit(
        result.fold(
          (exception) {
            AppLogger.error('Failed to load progress', exception);
            return const ProgressError();
          },
          (exercises) => ProgressLoaded(
            exercises: exercises,
            selectedExerciseName: exercises.isEmpty
                ? ''
                : exercises.first.exerciseName,
          ),
        ),
      );
    } while (_reloadPending && !isClosed);
  }

  /// Switches the chip without re-reading storage.
  void _onExerciseSelected(
    ProgressExerciseSelected event,
    Emitter<ProgressState> emit,
  ) {
    final current = state;
    if (current is! ProgressLoaded) return;
    emit(
      ProgressLoaded(
        exercises: current.exercises,
        selectedExerciseName: event.exerciseName,
      ),
    );
  }
}
