import 'package:equatable/equatable.dart';

sealed class DeleteWorkoutSessionEvent extends Equatable {
  const DeleteWorkoutSessionEvent();
}

final class DeleteWorkoutSessionConfirmed extends DeleteWorkoutSessionEvent {
  const DeleteWorkoutSessionConfirmed({required this.sessionId});

  final String sessionId;

  @override
  List<Object?> get props => [sessionId];
}
