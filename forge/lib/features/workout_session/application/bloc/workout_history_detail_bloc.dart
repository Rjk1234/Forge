import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:forge/core/logger/app_logger.dart';
import 'package:forge/features/workout_session/application/bloc/workout_history_detail_event.dart';
import 'package:forge/features/workout_session/application/bloc/workout_history_detail_state.dart';
import 'package:forge/features/workout_session/application/use_cases/get_workout_history_detail_use_case.dart';

class WorkoutHistoryDetailBloc
    extends Bloc<WorkoutHistoryDetailEvent, WorkoutHistoryDetailState> {
  WorkoutHistoryDetailBloc({required this._getDetail})
    : super(const WorkoutHistoryDetailInitial()) {
    on<WorkoutHistoryDetailLoadRequested>(_onLoadRequested);
  }

  final GetWorkoutHistoryDetailUseCase _getDetail;

  /// Session to reload right after the running load; null when none queued.
  String? _pendingSessionId;

  Future<void> _onLoadRequested(
    WorkoutHistoryDetailLoadRequested event,
    Emitter<WorkoutHistoryDetailState> emit,
  ) async {
    if (state is WorkoutHistoryDetailLoading) {
      _pendingSessionId = event.sessionId;
      return;
    }
    var sessionId = event.sessionId;
    do {
      _pendingSessionId = null;
      emit(const WorkoutHistoryDetailLoading());
      final result = await _getDetail(sessionId);
      emit(
        result.fold((exception) {
          AppLogger.error('Failed to load workout detail', exception);
          return const WorkoutHistoryDetailError();
        }, (session) => WorkoutHistoryDetailSuccess(session: session)),
      );
      sessionId = _pendingSessionId ?? sessionId;
    } while (_pendingSessionId != null && !isClosed);
  }
}
