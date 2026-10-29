import 'package:equatable/equatable.dart';

sealed class WorkoutHistoryEvent extends Equatable {
  const WorkoutHistoryEvent();
}

final class WorkoutHistoryLoadRequested extends WorkoutHistoryEvent {
  const WorkoutHistoryLoadRequested();

  @override
  List<Object?> get props => [];
}
