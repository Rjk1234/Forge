import 'package:equatable/equatable.dart';

sealed class WorkoutHistoryDetailEvent extends Equatable {
  const WorkoutHistoryDetailEvent();
}

final class WorkoutHistoryDetailLoadRequested
    extends WorkoutHistoryDetailEvent {
  const WorkoutHistoryDetailLoadRequested({required this.sessionId});

  final String sessionId;

  @override
  List<Object?> get props => [sessionId];
}
