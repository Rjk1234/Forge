import 'package:equatable/equatable.dart';
import 'package:forge/features/workout_session/domain/entities/workout_session.dart';

sealed class WorkoutHistoryDetailState extends Equatable {
  const WorkoutHistoryDetailState();
}

final class WorkoutHistoryDetailInitial extends WorkoutHistoryDetailState {
  const WorkoutHistoryDetailInitial();

  @override
  List<Object?> get props => [];
}

final class WorkoutHistoryDetailLoading extends WorkoutHistoryDetailState {
  const WorkoutHistoryDetailLoading();

  @override
  List<Object?> get props => [];
}

final class WorkoutHistoryDetailSuccess extends WorkoutHistoryDetailState {
  const WorkoutHistoryDetailSuccess({required this.session});

  final WorkoutSession session;

  @override
  List<Object?> get props => [session];
}

final class WorkoutHistoryDetailError extends WorkoutHistoryDetailState {
  const WorkoutHistoryDetailError();

  @override
  List<Object?> get props => [];
}
