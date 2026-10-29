/// Extra data carried by the pre-start route when it is opened from a
/// scheduled day.
class WorkoutPreStartRouteArgs {
  const WorkoutPreStartRouteArgs({this.scheduledWeekday});

  final int? scheduledWeekday;
}
