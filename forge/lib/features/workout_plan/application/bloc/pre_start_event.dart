import 'package:equatable/equatable.dart';

sealed class PreStartEvent extends Equatable {
  const PreStartEvent();
}

final class PreStartRequested extends PreStartEvent {
  const PreStartRequested({required this.planId, this.scheduledWeekday});

  final String planId;
  final int? scheduledWeekday;

  @override
  List<Object?> get props => [planId, scheduledWeekday];
}

final class PreStartRetried extends PreStartEvent {
  const PreStartRetried({required this.planId, this.scheduledWeekday});

  final String planId;
  final int? scheduledWeekday;

  @override
  List<Object?> get props => [planId, scheduledWeekday];
}
