import 'package:equatable/equatable.dart';

sealed class AssignScheduleEvent extends Equatable {
  const AssignScheduleEvent();
}

/// Dispatched once from [AssignScheduleScreen.initState] with the `planId`
/// route parameter.
final class AssignScheduleInitialized extends AssignScheduleEvent {
  const AssignScheduleInitialized(this.planId);

  final String planId;

  @override
  List<Object> get props => [planId];
}

/// Dispatched on every day-chip tap, regardless of its current state.
final class DayToggled extends AssignScheduleEvent {
  const DayToggled(this.weekday);

  /// 1–7
  final int weekday;

  @override
  List<Object> get props => [weekday];
}

final class SaveRequested extends AssignScheduleEvent {
  const SaveRequested();

  @override
  List<Object> get props => [];
}

final class RetrySaveRequested extends AssignScheduleEvent {
  const RetrySaveRequested();

  @override
  List<Object> get props => [];
}
