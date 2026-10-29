import 'package:equatable/equatable.dart';
import 'package:forge/features/workout_session/domain/entities/workout_session.dart';

sealed class WorkoutSummaryState extends Equatable {
  const WorkoutSummaryState();
}

final class WorkoutSummaryInitial extends WorkoutSummaryState {
  const WorkoutSummaryInitial();

  @override
  List<Object?> get props => [];
}

final class WorkoutSummaryLoading extends WorkoutSummaryState {
  const WorkoutSummaryLoading({required this.planName});

  final String planName;

  @override
  List<Object?> get props => [planName];
}

final class WorkoutSummarySuccess extends WorkoutSummaryState {
  const WorkoutSummarySuccess({required this.session});

  final WorkoutSession session;

  @override
  List<Object?> get props => [session];
}

final class WorkoutSummaryError extends WorkoutSummaryState {
  const WorkoutSummaryError({
    required this.planName,
    required this.sessionId,
    this.isRetryable = true,
  });

  final String planName;
  final String sessionId;

  /// False when the log itself is invalid, so saving again cannot succeed.
  final bool isRetryable;

  @override
  List<Object?> get props => [planName, sessionId, isRetryable];
}
