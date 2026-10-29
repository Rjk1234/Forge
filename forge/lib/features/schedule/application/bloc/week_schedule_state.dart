import 'package:equatable/equatable.dart';

import '../../domain/entities/weekly_schedule.dart';

sealed class WeekScheduleState extends Equatable {
  const WeekScheduleState();
}

final class WeekScheduleInitial extends WeekScheduleState {
  const WeekScheduleInitial();

  @override
  List<Object?> get props => [];
}

final class WeekScheduleLoading extends WeekScheduleState {
  const WeekScheduleLoading();

  @override
  List<Object?> get props => [];
}

final class WeekSchedulePopulated extends WeekScheduleState {
  const WeekSchedulePopulated(this.schedule);

  final WeeklySchedule schedule;

  @override
  List<Object?> get props => [schedule];
}

final class WeekScheduleEmpty extends WeekScheduleState {
  const WeekScheduleEmpty();

  @override
  List<Object?> get props => [];
}

final class WeekScheduleError extends WeekScheduleState {
  const WeekScheduleError();

  @override
  List<Object?> get props => [];
}
