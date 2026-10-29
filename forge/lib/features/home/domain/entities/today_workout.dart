import 'package:equatable/equatable.dart';
import 'package:forge/core/enums/exercise_type.dart';
import 'package:forge/features/home/domain/entities/planned_exercise.dart';

class TodayWorkout extends Equatable {
  const TodayWorkout({
    required this.planId,
    required this.planName,
    required this.exerciseCount,
    required this.dominantType,
    this.firstExerciseRestSec,
    this.exercises = const [],
    this.muscleGroups = const [],
    this.estimatedMinutes = 0,
    this.plannedVolumeKg = 0,
    this.totalSets = 0,
    this.isCompletedToday = false,
  });

  final String planId;
  final String planName;
  final int exerciseCount;

  /// Mode of ExerciseType across all plan exercises.
  /// Tie-break order: weighted > bodyweight > timeBased.
  final ExerciseType dominantType;

  /// Rest period of the first exercise in the plan, in seconds.
  /// Null when the plan has no exercises (FR-003).
  final int? firstExerciseRestSec;

  /// The plan's exercises in order, with their targets.
  final List<PlannedExercise> exercises;

  /// Distinct muscle groups trained, in plan order.
  final List<String> muscleGroups;

  /// Rough session length from the planned sets and rests.
  final int estimatedMinutes;

  /// Sum of sets x reps x weight over the weighted exercises.
  final double plannedVolumeKg;
  final int totalSets;

  /// A workout of this plan was already completed today.
  final bool isCompletedToday;

  @override
  List<Object?> get props => [
    planId,
    planName,
    exerciseCount,
    dominantType,
    firstExerciseRestSec,
    exercises,
    muscleGroups,
    estimatedMinutes,
    plannedVolumeKg,
    totalSets,
    isCompletedToday,
  ];
}
