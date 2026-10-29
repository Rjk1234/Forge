import 'package:equatable/equatable.dart';

import 'schedule_day.dart';

class WeeklySchedule extends Equatable {
  const WeeklySchedule({required this.days});

  /// Always 7 entries: index 0 = Monday (weekday 1) … index 6 = Sunday (weekday 7).
  final List<ScheduleDay> days;

  @override
  List<Object?> get props => [days];
}
