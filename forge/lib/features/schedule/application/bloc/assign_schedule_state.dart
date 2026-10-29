import 'package:equatable/equatable.dart';

sealed class AssignScheduleState extends Equatable {
  const AssignScheduleState();
}

final class AssignScheduleInitial extends AssignScheduleState {
  const AssignScheduleInitial();

  @override
  List<Object> get props => [];
}

final class AssignScheduleLoading extends AssignScheduleState {
  const AssignScheduleLoading();

  @override
  List<Object> get props => [];
}

final class AssignScheduleReady extends AssignScheduleState {
  const AssignScheduleReady({
    required this.planId,
    required this.planName,
    required this.originalDays,
    required this.selectedDays,
    required this.occupiedDays,
    required this.conflicts,
  });

  final String planId;
  final String planName;

  /// Snapshot of the plan's days at load time — the "previous" side of the
  /// save diff.
  final Set<int> originalDays;

  /// The user's live selection, starts equal to [originalDays].
  final Set<int> selectedDays;

  /// The fixed occupancy map conflicts are checked against.
  final Map<int, String> occupiedDays;

  /// Derived: `{d: occupiedDays[d] for d in selectedDays if d in occupiedDays}`.
  final Map<int, String> conflicts;

  bool get canSave => selectedDays.isNotEmpty && conflicts.isEmpty;

  /// Drives "New Schedule" vs "Edit Schedule" app bar title.
  bool get isEditMode => originalDays.isNotEmpty;

  AssignScheduleReady copyWith({
    Set<int>? selectedDays,
    Map<int, String>? conflicts,
  }) {
    return AssignScheduleReady(
      planId: planId,
      planName: planName,
      originalDays: originalDays,
      selectedDays: selectedDays ?? this.selectedDays,
      occupiedDays: occupiedDays,
      conflicts: conflicts ?? this.conflicts,
    );
  }

  @override
  List<Object> get props => [
    planId,
    planName,
    originalDays,
    selectedDays,
    occupiedDays,
    conflicts,
  ];
}

final class AssignScheduleInvalidPlan extends AssignScheduleState {
  const AssignScheduleInvalidPlan(this.planId);

  final String planId;

  @override
  List<Object> get props => [planId];
}

final class AssignScheduleSaving extends AssignScheduleState {
  const AssignScheduleSaving({required this.readyState});

  final AssignScheduleReady readyState;

  @override
  List<Object> get props => [readyState];
}

final class AssignScheduleSaved extends AssignScheduleState {
  const AssignScheduleSaved();

  @override
  List<Object> get props => [];
}

final class AssignScheduleSaveFailure extends AssignScheduleState {
  const AssignScheduleSaveFailure({required this.readyState});

  final AssignScheduleReady readyState;

  @override
  List<Object> get props => [readyState];
}
