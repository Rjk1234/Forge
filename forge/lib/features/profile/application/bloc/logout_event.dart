import 'package:equatable/equatable.dart';

sealed class LogoutEvent extends Equatable {
  const LogoutEvent();
}

final class LogoutConfirmed extends LogoutEvent {
  const LogoutConfirmed();

  @override
  List<Object?> get props => [];
}
