import 'package:equatable/equatable.dart';

class ScheduledPlanRef extends Equatable {
  const ScheduledPlanRef({
    required this.planId,
    required this.planName,
    required this.recurrenceLabel,
  });

  final String planId;
  final String planName;
  final String recurrenceLabel;

  @override
  List<Object?> get props => [planId, planName, recurrenceLabel];
}

class ScheduleDay extends Equatable {
  const ScheduleDay({
    required this.weekday,
    required this.date,
    required this.isToday,
    this.assignedPlan,
  });

  /// ISO weekday: 1=Monday … 7=Sunday.
  final int weekday;
  final DateTime date;
  final bool isToday;
  final ScheduledPlanRef? assignedPlan;

  @override
  List<Object?> get props => [weekday, date, isToday, assignedPlan];
}
