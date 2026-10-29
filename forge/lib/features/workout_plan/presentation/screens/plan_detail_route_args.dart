/// Extra data carried by the plan-detail route.
class PlanDetailRouteArgs {
  const PlanDetailRouteArgs({this.shouldShowStartWorkout = true});

  /// False when the plan is opened for a day other than today, so the page
  /// must not offer to start the workout.
  final bool shouldShowStartWorkout;
}
