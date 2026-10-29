import 'package:equatable/equatable.dart';
import 'package:forge/core/enums/exercise_type.dart';
import 'package:forge/features/workout_session/application/models/edit_set_entry.dart';

/// One exercise in the edit form, identified by its snapshot data.
class EditExerciseEntry extends Equatable {
  const EditExerciseEntry({
    required this.exerciseId,
    required this.exerciseName,
    required this.type,
    required this.sets,
  });

  final String exerciseId;
  final String exerciseName;
  final ExerciseType type;
  final List<EditSetEntry> sets;

  EditExerciseEntry withSets(List<EditSetEntry> sets) => EditExerciseEntry(
    exerciseId: exerciseId,
    exerciseName: exerciseName,
    type: type,
    sets: sets,
  );

  @override
  List<Object?> get props => [exerciseId, exerciseName, type, sets];
}
