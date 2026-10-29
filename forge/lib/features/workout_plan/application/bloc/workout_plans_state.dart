import 'package:equatable/equatable.dart';
import 'package:forge/features/workout_plan/domain/entities/workout_plan.dart';

sealed class WorkoutPlansState extends Equatable {
  const WorkoutPlansState();
}

final class WorkoutPlansInitial extends WorkoutPlansState {
  const WorkoutPlansInitial();

  @override
  List<Object> get props => [];
}

final class WorkoutPlansLoading extends WorkoutPlansState {
  const WorkoutPlansLoading();

  @override
  List<Object> get props => [];
}

final class WorkoutPlansPopulated extends WorkoutPlansState {
  const WorkoutPlansPopulated({required this.plans});

  final List<WorkoutPlan> plans;

  @override
  List<Object> get props => [plans];
}

final class WorkoutPlansEmpty extends WorkoutPlansState {
  const WorkoutPlansEmpty();

  @override
  List<Object> get props => [];
}

final class WorkoutPlansError extends WorkoutPlansState {
  const WorkoutPlansError();

  @override
  List<Object> get props => [];
}
