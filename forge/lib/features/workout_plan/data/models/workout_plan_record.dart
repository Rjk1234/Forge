import 'plan_exercise_record.dart';

/// A user-created workout plan keyed by [planId]. Plan data is independent of completed workout history — editing a plan never rewrites past session records.
class WorkoutPlanRecord {
  final String planId;

  final String name;

  /// Ordered list of exercises for this plan.
  final List<PlanExerciseRecord> planExercises;

  final DateTime createdAt;

  final DateTime updatedAt;

  const WorkoutPlanRecord({
    required this.planId,
    required this.name,
    required this.planExercises,
    required this.createdAt,
    required this.updatedAt,
  });
}
