import 'package:equatable/equatable.dart';

sealed class DeleteWorkoutSessionState extends Equatable {
  const DeleteWorkoutSessionState();

  @override
  List<Object?> get props => [];
}

final class DeleteWorkoutSessionConfirmation extends DeleteWorkoutSessionState {
  const DeleteWorkoutSessionConfirmation();
}

final class DeleteWorkoutSessionDeleting extends DeleteWorkoutSessionState {
  const DeleteWorkoutSessionDeleting();
}

final class DeleteWorkoutSessionSuccess extends DeleteWorkoutSessionState {
  const DeleteWorkoutSessionSuccess();
}

final class DeleteWorkoutSessionFailure extends DeleteWorkoutSessionState {
  const DeleteWorkoutSessionFailure();
}
