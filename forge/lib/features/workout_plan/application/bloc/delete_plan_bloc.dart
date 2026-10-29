import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:forge/features/workout_plan/application/bloc/delete_plan_event.dart';
import 'package:forge/features/workout_plan/application/bloc/delete_plan_state.dart';
import 'package:forge/features/workout_plan/domain/usecases/delete_workout_plan_usecase.dart';

class DeletePlanBloc extends Bloc<DeletePlanEvent, DeletePlanState> {
  DeletePlanBloc({required this.deleteWorkoutPlan})
    : super(const DeletePlanConfirmation()) {
    on<DeletePlanConfirmed>(_onConfirmed);
  }

  final DeleteWorkoutPlanUseCase deleteWorkoutPlan;

  Future<void> _onConfirmed(
    DeletePlanConfirmed event,
    Emitter<DeletePlanState> emit,
  ) async {
    emit(const DeletePlanDeleting());
    final result = await deleteWorkoutPlan(event.planId);
    result.fold(
      (failure) => emit(const DeletePlanFailure()),
      (_) => emit(const DeletePlanSuccess()),
    );
  }
}
