import 'package:equatable/equatable.dart';

sealed class WeekScheduleEvent extends Equatable {
  const WeekScheduleEvent();
}

final class WeekScheduleRequested extends WeekScheduleEvent {
  const WeekScheduleRequested();

  @override
  List<Object?> get props => [];
}

final class WeekScheduleRetried extends WeekScheduleEvent {
  const WeekScheduleRetried();

  @override
  List<Object?> get props => [];
}
