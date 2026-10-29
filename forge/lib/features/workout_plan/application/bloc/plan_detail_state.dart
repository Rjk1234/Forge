import 'package:equatable/equatable.dart';
import 'package:forge/features/workout_plan/domain/entities/workout_plan_detail.dart';

sealed class PlanDetailState extends Equatable {
  const PlanDetailState();
}

final class PlanDetailInitial extends PlanDetailState {
  const PlanDetailInitial();

  @override
  List<Object> get props => [];
}

final class PlanDetailLoading extends PlanDetailState {
  const PlanDetailLoading();

  @override
  List<Object> get props => [];
}

final class PlanDetailLoaded extends PlanDetailState {
  const PlanDetailLoaded({
    required this.plan,
    this.shouldShowStartWorkout = true,
  });

  final WorkoutPlanDetail plan;

  /// False when the plan is shown for a day other than today.
  final bool shouldShowStartWorkout;

  @override
  List<Object> get props => [plan, shouldShowStartWorkout];
}

final class PlanDetailNotFound extends PlanDetailState {
  const PlanDetailNotFound();

  @override
  List<Object> get props => [];
}
