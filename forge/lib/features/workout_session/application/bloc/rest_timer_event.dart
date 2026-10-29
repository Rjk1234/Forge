import 'package:equatable/equatable.dart';

sealed class RestTimerEvent extends Equatable {
  const RestTimerEvent();
}

final class RestTimerStarted extends RestTimerEvent {
  const RestTimerStarted({required this.restPeriodSec});

  final int restPeriodSec;

  @override
  List<Object?> get props => [restPeriodSec];
}

final class RestTimerTicked extends RestTimerEvent {
  const RestTimerTicked();

  @override
  List<Object?> get props => [];
}

final class RestTimerSkipped extends RestTimerEvent {
  const RestTimerSkipped();

  @override
  List<Object?> get props => [];
}
