import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:forge/core/logger/app_logger.dart';
import 'package:forge/features/personal_bests/application/bloc/pb_event.dart';
import 'package:forge/features/personal_bests/application/bloc/pb_state.dart';
import 'package:forge/features/personal_bests/application/use_cases/get_personal_bests_use_case.dart';

class PbBloc extends Bloc<PbEvent, PbState> {
  PbBloc({required this._getPersonalBests}) : super(const PbInitial()) {
    on<PbLoadRequested>(_onLoadRequested);
  }

  final GetPersonalBestsUseCase _getPersonalBests;

  /// A reload asked for while one is running; served right after it.
  bool _reloadPending = false;

  Future<void> _onLoadRequested(
    PbLoadRequested event,
    Emitter<PbState> emit,
  ) async {
    if (state is PbLoading) {
      _reloadPending = true;
      return;
    }
    do {
      _reloadPending = false;
      emit(const PbLoading());
      final result = await _getPersonalBests();
      emit(
        result.fold((exception) {
          AppLogger.error('Failed to load personal bests', exception);
          return const PbError();
        }, (records) => PbLoaded(records: records)),
      );
    } while (_reloadPending && !isClosed);
  }
}
