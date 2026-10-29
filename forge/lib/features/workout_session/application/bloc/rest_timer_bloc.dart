import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:forge/features/workout_session/application/bloc/rest_timer_event.dart';
import 'package:forge/features/workout_session/application/bloc/rest_timer_state.dart';

class RestTimerBloc extends Bloc<RestTimerEvent, RestTimerState> {
  RestTimerBloc() : super(const RestTimerInitial()) {
    on<RestTimerStarted>(_onStarted);
    on<RestTimerTicked>(_onTicked);
    on<RestTimerSkipped>(_onSkipped);
  }

  static const Duration _tickInterval = Duration(seconds: 1);

  Timer? _timer;

  void _onStarted(RestTimerStarted event, Emitter<RestTimerState> emit) {
    _timer?.cancel();
    emit(
      RestTimerRunning(
        totalSec: event.restPeriodSec,
        remainingSec: event.restPeriodSec,
      ),
    );
    _timer = Timer.periodic(_tickInterval, (_) => add(const RestTimerTicked()));
  }

  void _onTicked(RestTimerTicked event, Emitter<RestTimerState> emit) {
    final current = state;
    if (current is! RestTimerRunning || current.navigateBack) return;
    if (current.remainingSec > 1) {
      emit(current.copyWith(remainingSec: current.remainingSec - 1));
      return;
    }
    _timer?.cancel();
    emit(current.copyWith(remainingSec: 0, navigateBack: true));
  }

  void _onSkipped(RestTimerSkipped event, Emitter<RestTimerState> emit) {
    final current = state;
    if (current is! RestTimerRunning || current.navigateBack) return;
    _timer?.cancel();
    emit(current.copyWith(navigateBack: true));
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    return super.close();
  }
}
