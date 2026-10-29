import 'package:equatable/equatable.dart';
import 'package:forge/features/workout_plan/domain/entities/workout_plan_detail.dart';

sealed class PreStartState extends Equatable {
  const PreStartState();
}

final class PreStartInitial extends PreStartState {
  const PreStartInitial();

  @override
  List<Object?> get props => [];
}

final class PreStartLoading extends PreStartState {
  const PreStartLoading();

  @override
  List<Object?> get props => [];
}

final class PreStartLoaded extends PreStartState {
  const PreStartLoaded({
    required this.plan,
    this.scheduledWeekday,
    required this.isScheduledForToday,
    this.isCompletedToday = false,
  });

  final WorkoutPlanDetail plan;
  final int? scheduledWeekday;
  final bool isScheduledForToday;

  /// The plan already has a completed workout today; starting it again asks
  /// for confirmation.
  final bool isCompletedToday;

  @override
  List<Object?> get props => [
    plan,
    scheduledWeekday,
    isScheduledForToday,
    isCompletedToday,
  ];
}

final class PreStartUnavailable extends PreStartState {
  const PreStartUnavailable();

  @override
  List<Object?> get props => [];
}

final class PreStartError extends PreStartState {
  const PreStartError();

  @override
  List<Object?> get props => [];
}
