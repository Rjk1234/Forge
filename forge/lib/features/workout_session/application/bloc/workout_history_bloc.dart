import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:forge/core/utils/format_utils.dart';
import 'package:forge/features/workout_session/application/bloc/workout_history_event.dart';
import 'package:forge/features/workout_session/application/bloc/workout_history_state.dart';
import 'package:forge/features/workout_session/application/models/history_month_group.dart';
import 'package:forge/features/workout_session/application/use_cases/get_workout_history_use_case.dart';
import 'package:forge/features/workout_session/domain/entities/workout_session.dart';

class WorkoutHistoryBloc
    extends Bloc<WorkoutHistoryEvent, WorkoutHistoryState> {
  WorkoutHistoryBloc({required this._getWorkoutHistory})
    : super(const WorkoutHistoryInitial()) {
    on<WorkoutHistoryLoadRequested>(_onLoadRequested);
  }

  final GetWorkoutHistoryUseCase _getWorkoutHistory;

  Future<void> _onLoadRequested(
    WorkoutHistoryLoadRequested event,
    Emitter<WorkoutHistoryState> emit,
  ) async {
    emit(const WorkoutHistoryLoading());
    final result = await _getWorkoutHistory();
    emit(
      result.fold(
        (_) => const WorkoutHistoryError(),
        (sessions) => sessions.isEmpty
            ? const WorkoutHistoryEmpty()
            : WorkoutHistorySuccess(groups: _buildGroups(sessions)),
      ),
    );
  }

  /// Groups newest-first [sessions] into consecutive calendar-month buckets.
  List<HistoryMonthGroup> _buildGroups(List<WorkoutSession> sessions) {
    final groups = <HistoryMonthGroup>[];
    for (final session in sessions) {
      final label = formatMonthYear(session.startedAt);
      if (groups.isNotEmpty && groups.last.label == label) {
        groups.last.sessions.add(session);
      } else {
        groups.add(HistoryMonthGroup(label: label, sessions: [session]));
      }
    }
    return groups;
  }
}
