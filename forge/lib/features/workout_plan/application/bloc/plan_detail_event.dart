import 'package:equatable/equatable.dart';

sealed class PlanDetailEvent extends Equatable {
  const PlanDetailEvent();
}

final class PlanDetailLoadRequested extends PlanDetailEvent {
  const PlanDetailLoadRequested({
    required this.planId,
    this.shouldShowStartWorkout,
  });

  final String planId;

  /// Whether the page offers Start Workout. Null keeps the value of the
  /// previous load (true for the first one), so a reload does not reset it.
  final bool? shouldShowStartWorkout;

  @override
  List<Object?> get props => [planId, shouldShowStartWorkout];
}
