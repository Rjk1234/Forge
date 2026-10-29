import 'package:equatable/equatable.dart';

/// Immutable projection of a workout plan used on the Plans list screen.
///
/// Carries only the fields needed to render a plan card:
/// id (for navigation), name, exerciseCount (derived from planExercises.length),
/// and createdAt (used for newest-first sort in the repository).
class WorkoutPlan extends Equatable {
  const WorkoutPlan({
    required this.id,
    required this.name,
    required this.exerciseCount,
    required this.createdAt,
  });

  final String id;
  final String name;
  final int exerciseCount;
  final DateTime createdAt;

  @override
  List<Object> get props => [id, name, exerciseCount, createdAt];
}
