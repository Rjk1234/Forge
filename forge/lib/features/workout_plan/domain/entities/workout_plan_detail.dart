import 'package:equatable/equatable.dart';
import 'package:forge/features/workout_plan/domain/entities/plan_exercise.dart';

/// Full workout plan entity used by the create/edit form.
///
/// Distinct from [WorkoutPlan] (the list-view projection) — carries the
/// complete exercise list with all target fields.
class WorkoutPlanDetail extends Equatable {
  const WorkoutPlanDetail({
    required this.id,
    required this.name,
    required this.exercises,
    required this.createdAt,
  });

  final String id;
  final String name;
  final List<PlanExercise> exercises;
  final DateTime createdAt;

  @override
  List<Object> get props => [id, name, exercises, createdAt];
}
