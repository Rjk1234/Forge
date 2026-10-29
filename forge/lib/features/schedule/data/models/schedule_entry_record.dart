/// A weekly schedule assignment keyed by [weekday] (1=Mon … 7=Sun). At most one plan per weekday — assigning a new plan replaces the existing one.
class ScheduleEntryRecord {
  /// 1 = Monday … 7 = Sunday
  final int weekday;

  final String planId;

  /// Snapshot of plan name for display without a separate lookup.
  final String planName;

  const ScheduleEntryRecord({
    required this.weekday,
    required this.planId,
    required this.planName,
  });
}
