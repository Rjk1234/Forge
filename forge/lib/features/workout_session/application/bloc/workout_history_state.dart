import 'package:equatable/equatable.dart';
import 'package:forge/features/workout_session/application/models/history_month_group.dart';

sealed class WorkoutHistoryState extends Equatable {
  const WorkoutHistoryState();
}

final class WorkoutHistoryInitial extends WorkoutHistoryState {
  const WorkoutHistoryInitial();

  @override
  List<Object?> get props => [];
}

final class WorkoutHistoryLoading extends WorkoutHistoryState {
  const WorkoutHistoryLoading();

  @override
  List<Object?> get props => [];
}

final class WorkoutHistorySuccess extends WorkoutHistoryState {
  const WorkoutHistorySuccess({required this.groups});

  final List<HistoryMonthGroup> groups;

  @override
  List<Object?> get props => [groups];
}

/// The read succeeded and there are no sessions. Never used for read errors.
final class WorkoutHistoryEmpty extends WorkoutHistoryState {
  const WorkoutHistoryEmpty();

  @override
  List<Object?> get props => [];
}

final class WorkoutHistoryError extends WorkoutHistoryState {
  const WorkoutHistoryError();

  @override
  List<Object?> get props => [];
}
