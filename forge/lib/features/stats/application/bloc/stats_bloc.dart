import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:forge/core/logger/app_logger.dart';
import 'package:forge/features/stats/application/bloc/stats_event.dart';
import 'package:forge/features/stats/application/bloc/stats_state.dart';
import 'package:forge/features/stats/application/use_cases/get_statistics_use_case.dart';

class StatsBloc extends Bloc<StatsEvent, StatsState> {
  StatsBloc({required this._getStatistics}) : super(const StatsInitial()) {
    on<StatsLoadRequested>(_onLoadRequested);
  }

  final GetStatisticsUseCase _getStatistics;

  /// A reload asked for while one is running; served right after it.
  bool _reloadPending = false;

  Future<void> _onLoadRequested(
    StatsLoadRequested event,
    Emitter<StatsState> emit,
  ) async {
    if (state is StatsLoading) {
      _reloadPending = true;
      return;
    }
    do {
      _reloadPending = false;
      emit(const StatsLoading());
      final result = await _getStatistics();
      emit(
        result.fold(
          (exception) {
            AppLogger.error('Failed to load statistics', exception);
            return const StatsError();
          },
          (summary) =>
              StatsLoaded(stats: summary.stats, exercises: summary.exercises),
        ),
      );
    } while (_reloadPending && !isClosed);
  }
}
