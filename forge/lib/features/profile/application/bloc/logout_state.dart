import 'package:equatable/equatable.dart';

sealed class LogoutState extends Equatable {
  const LogoutState();
}

final class LogoutConfirmation extends LogoutState {
  const LogoutConfirmation();

  @override
  List<Object?> get props => [];
}

final class LogoutInProgress extends LogoutState {
  const LogoutInProgress();

  @override
  List<Object?> get props => [];
}

final class LogoutSuccess extends LogoutState {
  const LogoutSuccess();

  @override
  List<Object?> get props => [];
}

final class LogoutFailure extends LogoutState {
  const LogoutFailure();

  @override
  List<Object?> get props => [];
}
