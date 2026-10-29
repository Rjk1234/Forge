import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecases/get_weekly_schedule_usecase.dart';
import 'week_schedule_event.dart';
import 'week_schedule_state.dart';

class WeekScheduleBloc extends Bloc<WeekScheduleEvent, WeekScheduleState> {
  WeekScheduleBloc({required this.getWeeklySchedule})
    : super(const WeekScheduleInitial()) {
    on<WeekScheduleRequested>(_onRequested);
    on<WeekScheduleRetried>(_onRetried);
  }

  final GetWeeklyScheduleUseCase getWeeklySchedule;

  FutureOr<void> _onRequested(
    WeekScheduleRequested event,
    Emitter<WeekScheduleState> emit,
  ) async {
    if (state is WeekScheduleLoading) return;
    await _load(emit);
  }

  FutureOr<void> _onRetried(
    WeekScheduleRetried event,
    Emitter<WeekScheduleState> emit,
  ) async {
    if (state is WeekScheduleLoading) return;
    await _load(emit);
  }

  Future<void> _load(Emitter<WeekScheduleState> emit) async {
    emit(const WeekScheduleLoading());
    final result = await getWeeklySchedule();
    result.fold((failure) => emit(const WeekScheduleError()), (schedule) {
      final hasAnyPlan = schedule.days.any((d) => d.assignedPlan != null);
      if (hasAnyPlan) {
        emit(WeekSchedulePopulated(schedule));
      } else {
        emit(const WeekScheduleEmpty());
      }
    });
  }
}
