import 'package:equatable/equatable.dart';
import 'package:forge/core/enums/exercise_type.dart';

/// One exercise of today's plan, with the targets shown on Home.
class PlannedExercise extends Equatable {
  const PlannedExercise({
    required this.name,
    required this.type,
    required this.sets,
    required this.restSec,
    this.repetitions,
    this.weightKg,
    this.durationSec,
  });

  final String name;
  final ExerciseType type;
  final int sets;
  final int restSec;
  final int? repetitions;
  final double? weightKg;
  final int? durationSec;

  @override
  List<Object?> get props => [
    name,
    type,
    sets,
    restSec,
    repetitions,
    weightKg,
    durationSec,
  ];
}
