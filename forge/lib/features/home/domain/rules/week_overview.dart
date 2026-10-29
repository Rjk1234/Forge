import 'package:forge/features/home/domain/entities/next_workout.dart';
import 'package:forge/features/home/domain/entities/week_day_status.dart';

const int daysInWeek = 7;

/// Monday-first status of the week that contains [today].
///
/// [planned] and [completed] map a weekday to its scheduled plan and its
/// latest completed workout. A completed day wins over a planned one, and a
/// scheduled day before today without a workout is missed.
List<WeekDayStatus> buildWeekDays({
  required DateTime today,
  required Map<int, WeekPlanRef> planned,
  required Map<int, WeekSessionRef> completed,
}) {
  WeekDayState stateOf(int weekday) {
    if (completed.containsKey(weekday)) return WeekDayState.completed;
    if (!planned.containsKey(weekday)) return WeekDayState.rest;
    return weekday < today.weekday ? WeekDayState.missed : WeekDayState.planned;
  }

  return [
    for (var weekday = DateTime.monday; weekday <= DateTime.sunday; weekday++)
      WeekDayStatus(
        weekday: weekday,
        isToday: weekday == today.weekday,
        state: stateOf(weekday),
        plan: planned[weekday],
        session: completed[weekday],
      ),
  ];
}

/// "x of y": scheduled days finished out of all scheduled days.
({int done, int total}) weekProgress(List<WeekDayStatus> days) {
  final scheduled = days.where((day) => day.plan != null);
  return (
    done: scheduled.where((d) => d.state == WeekDayState.completed).length,
    total: scheduled.length,
  );
}

/// First scheduled day after today, wrapping past Sunday; null when nothing
/// else is scheduled. [planNameByWeekday] maps weekday to plan name.
NextWorkout? findNextWorkout({
  required int todayWeekday,
  required Map<int, String> planNameByWeekday,
}) {
  for (var offset = 1; offset < daysInWeek; offset++) {
    final weekday = (todayWeekday - 1 + offset) % daysInWeek + 1;
    final planName = planNameByWeekday[weekday];
    if (planName != null) {
      return NextWorkout(weekday: weekday, planName: planName);
    }
  }
  return null;
}
