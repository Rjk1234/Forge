import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:forge/features/workout_plan/application/bloc/workout_plans_event.dart';
import 'package:forge/features/workout_plan/application/bloc/workout_plans_state.dart';
import 'package:forge/features/workout_plan/domain/usecases/get_workout_plans_usecase.dart';

class WorkoutPlansBloc extends Bloc<WorkoutPlansEvent, WorkoutPlansState> {
  WorkoutPlansBloc({required this.getWorkoutPlans})
    : super(const WorkoutPlansInitial()) {
    on<WorkoutPlansLoadRequested>(_onLoadRequested);
  }

  final GetWorkoutPlansUseCase getWorkoutPlans;

  FutureOr<void> _onLoadRequested(
    WorkoutPlansLoadRequested event,
    Emitter<WorkoutPlansState> emit,
  ) async {
    final hasExistingData =
        state is WorkoutPlansPopulated || state is WorkoutPlansEmpty;

    if (!hasExistingData) {
      emit(const WorkoutPlansLoading());
    }

    final result = await getWorkoutPlans();
    result.fold(
      (failure) => emit(const WorkoutPlansError()),
      (plans) => plans.isEmpty
          ? emit(const WorkoutPlansEmpty())
          : emit(WorkoutPlansPopulated(plans: plans)),
    );
  }
}
