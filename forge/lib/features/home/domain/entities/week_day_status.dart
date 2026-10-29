import 'package:equatable/equatable.dart';

/// `missed` is a scheduled day before today that has no completed workout.
enum WeekDayState { completed, planned, missed, rest }

/// The plan scheduled on a weekday.
class WeekPlanRef extends Equatable {
  const WeekPlanRef({required this.planId, required this.planName});

  final String planId;
  final String planName;

  @override
  List<Object> get props => [planId, planName];
}

/// The most recent completed workout of a weekday, and how many there were.
class WeekSessionRef extends Equatable {
  const WeekSessionRef({
    required this.sessionId,
    required this.planName,
    required this.count,
  });

  final String sessionId;
  final String planName;
  final int count;

  @override
  List<Object> get props => [sessionId, planName, count];
}

/// One day of the current Monday-to-Sunday week on Home.
class WeekDayStatus extends Equatable {
  const WeekDayStatus({
    required this.weekday,
    required this.state,
    required this.isToday,
    this.plan,
    this.session,
  });

  /// 1 = Monday … 7 = Sunday.
  final int weekday;
  final WeekDayState state;
  final bool isToday;

  /// The plan scheduled that day, if any.
  final WeekPlanRef? plan;

  /// The latest workout completed that day, if any.
  final WeekSessionRef? session;

  @override
  List<Object?> get props => [weekday, state, isToday, plan, session];
}
