import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:forge/core/exceptions/app_exception.dart';
import 'package:forge/features/workout_session/application/bloc/workout_summary_event.dart';
import 'package:forge/features/workout_session/application/bloc/workout_summary_state.dart';
import 'package:forge/features/workout_session/domain/entities/workout_session.dart';
import 'package:forge/features/workout_session/domain/repositories/workout_session_repository.dart';
import 'package:forge/features/workout_session/domain/usecases/save_workout_session_usecase.dart';

class WorkoutSummaryBloc
    extends Bloc<WorkoutSummaryEvent, WorkoutSummaryState> {
  WorkoutSummaryBloc({required this._repository, required this._saveSession})
    : super(const WorkoutSummaryInitial()) {
    on<WorkoutSummaryStarted>(_onStarted);
    on<WorkoutSummaryRetryRequested>(_onRetryRequested);
  }

  final WorkoutSessionRepository _repository;
  final SaveWorkoutSessionUseCase _saveSession;

  WorkoutSession? _session;

  Future<void> _onStarted(
    WorkoutSummaryStarted event,
    Emitter<WorkoutSummaryState> emit,
  ) {
    _session = event.session;
    return _attemptSave(emit);
  }

  Future<void> _onRetryRequested(
    WorkoutSummaryRetryRequested event,
    Emitter<WorkoutSummaryState> emit,
  ) {
    if (state is WorkoutSummaryLoading) return Future.value();
    return _attemptSave(emit);
  }

  /// Skips the write when a previous attempt already persisted the session,
  /// so a retry can never create a duplicate record.
  Future<void> _attemptSave(Emitter<WorkoutSummaryState> emit) async {
    final session = _session;
    if (session == null) return;

    emit(WorkoutSummaryLoading(planName: session.planName));

    final existing = await _repository.getSessionById(session.sessionId);
    final alreadySaved = existing.fold((_) => null, (found) => found);
    if (alreadySaved != null) {
      emit(WorkoutSummarySuccess(session: alreadySaved));
      return;
    }

    final result = await _saveSession(session);
    emit(
      result.fold(
        (failure) => WorkoutSummaryError(
          planName: session.planName,
          sessionId: session.sessionId,
          isRetryable: failure is! ValidationException,
        ),
        (_) => WorkoutSummarySuccess(session: session),
      ),
    );
  }
}
