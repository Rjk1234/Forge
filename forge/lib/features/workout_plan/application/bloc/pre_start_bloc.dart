import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:forge/features/workout_plan/application/bloc/pre_start_event.dart';
import 'package:forge/features/workout_plan/application/bloc/pre_start_state.dart';
import 'package:forge/features/workout_plan/domain/usecases/get_workout_plan_by_id_usecase.dart';
import 'package:forge/features/workout_session/domain/usecases/has_completed_workout_today_usecase.dart';

class PreStartBloc extends Bloc<PreStartEvent, PreStartState> {
  PreStartBloc({
    required this.getWorkoutPlanById,
    required this.hasCompletedWorkoutToday,
  }) : super(const PreStartInitial()) {
    on<PreStartRequested>(_onRequested);
    on<PreStartRetried>(_onRetried);
  }

  final GetWorkoutPlanByIdUseCase getWorkoutPlanById;
  final HasCompletedWorkoutTodayUseCase hasCompletedWorkoutToday;

  Future<void> _onRequested(
    PreStartRequested event,
    Emitter<PreStartState> emit,
  ) => _load(event.planId, event.scheduledWeekday, emit);

  Future<void> _onRetried(PreStartRetried event, Emitter<PreStartState> emit) =>
      _load(event.planId, event.scheduledWeekday, emit);

  Future<void> _load(
    String planId,
    int? scheduledWeekday,
    Emitter<PreStartState> emit,
  ) async {
    if (state is PreStartLoading) return;
    emit(const PreStartLoading());
    final result = await getWorkoutPlanById(planId);
    final plan = result.toNullable();
    if (plan == null) return emit(const PreStartError());
    if (plan.exercises.isEmpty) return emit(const PreStartUnavailable());

    // A failed lookup must not block starting a workout.
    final isCompletedToday = (await hasCompletedWorkoutToday(
      planId,
    )).getOrElse((_) => false);
    final isScheduledToday =
        scheduledWeekday != null && scheduledWeekday == DateTime.now().weekday;
    emit(
      PreStartLoaded(
        plan: plan,
        scheduledWeekday: scheduledWeekday,
        isScheduledForToday: isScheduledToday,
        isCompletedToday: isCompletedToday,
      ),
    );
  }
}
