import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:forge/features/workout_plan/application/bloc/plan_detail_event.dart';
import 'package:forge/features/workout_plan/application/bloc/plan_detail_state.dart';
import 'package:forge/features/workout_plan/domain/usecases/get_workout_plan_by_id_usecase.dart';

class PlanDetailBloc extends Bloc<PlanDetailEvent, PlanDetailState> {
  PlanDetailBloc({required this.getWorkoutPlanById})
    : super(const PlanDetailInitial()) {
    on<PlanDetailLoadRequested>(_onLoadRequested);
  }

  final GetWorkoutPlanByIdUseCase getWorkoutPlanById;

  bool _shouldShowStartWorkout = true;

  FutureOr<void> _onLoadRequested(
    PlanDetailLoadRequested event,
    Emitter<PlanDetailState> emit,
  ) async {
    _shouldShowStartWorkout =
        event.shouldShowStartWorkout ?? _shouldShowStartWorkout;
    emit(const PlanDetailLoading());
    final result = await getWorkoutPlanById(event.planId);
    result.fold(
      (failure) => emit(const PlanDetailNotFound()),
      (plan) => emit(
        PlanDetailLoaded(
          plan: plan,
          shouldShowStartWorkout: _shouldShowStartWorkout,
        ),
      ),
    );
  }
}
