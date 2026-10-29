import 'package:equatable/equatable.dart';

/// Everything the assignment form needs at init, in one shape.
class ScheduleFormContext extends Equatable {
  const ScheduleFormContext({
    required this.planId,
    required this.planName,
    required this.currentDays,
    required this.occupiedDays,
  });

  final String planId;

  /// Null means the plan no longer exists — the screen renders the Invalid
  /// Plan state and [currentDays]/[occupiedDays] are not used.
  final String? planName;

  /// Weekdays (1–7) currently assigned to this plan. Empty means "New" mode.
  final Set<int> currentDays;

  /// Weekday → the *other* plan's name currently occupying it. Never
  /// contains a day that's also in [currentDays].
  final Map<int, String> occupiedDays;

  @override
  List<Object?> get props => [planId, planName, currentDays, occupiedDays];
}
