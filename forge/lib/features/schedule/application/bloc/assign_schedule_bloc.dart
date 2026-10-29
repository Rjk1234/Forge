import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:forge/features/schedule/application/bloc/assign_schedule_event.dart';
import 'package:forge/features/schedule/application/bloc/assign_schedule_state.dart';
import 'package:forge/features/schedule/domain/usecases/load_assignment_context_usecase.dart';
import 'package:forge/features/schedule/domain/usecases/save_schedule_assignment_usecase.dart';

class AssignScheduleBloc
    extends Bloc<AssignScheduleEvent, AssignScheduleState> {
  AssignScheduleBloc({
    required this.loadAssignmentContext,
    required this.saveScheduleAssignment,
  }) : super(const AssignScheduleInitial()) {
    on<AssignScheduleInitialized>(_onInitialized);
    on<DayToggled>(_onDayToggled);
    on<SaveRequested>(_onSaveRequested);
    on<RetrySaveRequested>(_onRetrySaveRequested);
  }

  final LoadAssignmentContextUseCase loadAssignmentContext;
  final SaveScheduleAssignmentUseCase saveScheduleAssignment;

  FutureOr<void> _onInitialized(
    AssignScheduleInitialized event,
    Emitter<AssignScheduleState> emit,
  ) async {
    emit(const AssignScheduleLoading());
    final result = await loadAssignmentContext(event.planId);

    result.fold(
      (failure) {
        emit(AssignScheduleInvalidPlan(event.planId));
      },
      (ctx) {
        final planName = ctx.planName;
        if (planName == null) {
          emit(AssignScheduleInvalidPlan(event.planId));
          return;
        }
        emit(
          AssignScheduleReady(
            planId: ctx.planId,
            planName: planName,
            originalDays: ctx.currentDays,
            selectedDays: ctx.currentDays,
            occupiedDays: ctx.occupiedDays,
            conflicts: const {},
          ),
        );
      },
    );
  }

  FutureOr<void> _onDayToggled(
    DayToggled event,
    Emitter<AssignScheduleState> emit,
  ) {
    final ready = state;
    if (ready is! AssignScheduleReady) return null;

    final selectedDays = Set<int>.of(ready.selectedDays);
    if (!selectedDays.remove(event.weekday)) {
      selectedDays.add(event.weekday);
    }

    final conflicts = {
      for (final d in selectedDays)
        if (ready.occupiedDays.containsKey(d)) d: ready.occupiedDays[d]!,
    };

    emit(ready.copyWith(selectedDays: selectedDays, conflicts: conflicts));
    return null;
  }

  FutureOr<void> _onSaveRequested(
    SaveRequested event,
    Emitter<AssignScheduleState> emit,
  ) async {
    final ready = state;
    if (ready is! AssignScheduleReady || !ready.canSave) return;

    await _save(ready, emit);
  }

  FutureOr<void> _onRetrySaveRequested(
    RetrySaveRequested event,
    Emitter<AssignScheduleState> emit,
  ) async {
    final failure = state;
    if (failure is! AssignScheduleSaveFailure) return;

    await _save(failure.readyState, emit);
  }

  Future<void> _save(
    AssignScheduleReady ready,
    Emitter<AssignScheduleState> emit,
  ) async {
    emit(AssignScheduleSaving(readyState: ready));

    final result = await saveScheduleAssignment(
      planId: ready.planId,
      planName: ready.planName,
      previousWeekdays: ready.originalDays,
      newWeekdays: ready.selectedDays,
    );

    result.fold(
      (failure) => emit(AssignScheduleSaveFailure(readyState: ready)),
      (_) => emit(const AssignScheduleSaved()),
    );
  }
}
