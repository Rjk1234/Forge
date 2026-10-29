import 'package:equatable/equatable.dart';
import 'package:forge/features/workout_session/domain/entities/workout_session.dart';

sealed class WorkoutSummaryEvent extends Equatable {
  const WorkoutSummaryEvent();
}

final class WorkoutSummaryStarted extends WorkoutSummaryEvent {
  const WorkoutSummaryStarted({required this.session});

  final WorkoutSession session;

  @override
  List<Object?> get props => [session];
}

final class WorkoutSummaryRetryRequested extends WorkoutSummaryEvent {
  const WorkoutSummaryRetryRequested();

  @override
  List<Object?> get props => [];
}
