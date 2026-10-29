/// A rule broken by a workout plan, with the exercise it belongs to (if any).
enum PlanViolationType {
  nameInvalid,
  exercisesRequired,
  setsInvalid,
  repetitionsInvalid,
  weightInvalid,
  durationInvalid,
  restInvalid,
  unexpectedField,
  unknownExercise,
}

class PlanViolation {
  const PlanViolation(this.type, {this.exerciseIndex});

  final PlanViolationType type;

  /// Index into the plan's exercise list; null for plan-level violations.
  final int? exerciseIndex;

  @override
  String toString() => exerciseIndex == null
      ? type.name
      : '${type.name}@exercise[$exerciseIndex]';
}
