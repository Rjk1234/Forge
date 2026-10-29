/// A rule broken by a workout log.
enum SessionViolationType {
  missingSessionId,
  missingPlanReference,
  noExercises,
  missingExerciseReference,
  exerciseWithoutSets,
  noValidLoggedSet,
  invalidSet,
  invalidDuration,
  invalidTimeRange,
  unknownExercise,
}

class SessionViolation {
  const SessionViolation(this.type, {this.exerciseIndex});

  final SessionViolationType type;

  /// Index into the session's exercise list; null for session-level rules.
  final int? exerciseIndex;

  @override
  String toString() => exerciseIndex == null
      ? type.name
      : '${type.name}@exercise[$exerciseIndex]';
}
