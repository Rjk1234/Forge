import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:forge/core/logger/app_logger.dart';
import 'package:forge/features/workout_session/application/bloc/delete_workout_session_event.dart';
import 'package:forge/features/workout_session/application/bloc/delete_workout_session_state.dart';
import 'package:forge/features/workout_session/domain/usecases/delete_workout_session_usecase.dart';

class DeleteWorkoutSessionBloc
    extends Bloc<DeleteWorkoutSessionEvent, DeleteWorkoutSessionState> {
  DeleteWorkoutSessionBloc({required this.deleteWorkoutSession})
    : super(const DeleteWorkoutSessionConfirmation()) {
    on<DeleteWorkoutSessionConfirmed>(_onConfirmed);
  }

  final DeleteWorkoutSessionUseCase deleteWorkoutSession;

  Future<void> _onConfirmed(
    DeleteWorkoutSessionConfirmed event,
    Emitter<DeleteWorkoutSessionState> emit,
  ) async {
    emit(const DeleteWorkoutSessionDeleting());
    final result = await deleteWorkoutSession(event.sessionId);
    result.fold((failure) {
      AppLogger.error('Failed to delete workout session', failure);
      emit(const DeleteWorkoutSessionFailure());
    }, (_) => emit(const DeleteWorkoutSessionSuccess()));
  }
}
