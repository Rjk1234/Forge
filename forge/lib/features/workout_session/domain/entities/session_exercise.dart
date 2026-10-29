import 'package:equatable/equatable.dart';
import 'package:forge/core/enums/exercise_type.dart';
import 'package:forge/features/workout_session/domain/entities/actual_set.dart';

/// Actual performance data for one exercise within a completed workout session.
/// All values are snapshots captured at finish time — subsequent plan edits
/// cannot alter this record.
class SessionExercise extends Equatable {
  const SessionExercise({
    required this.exerciseId,
    required this.exerciseName,
    required this.type,
    required this.actualSets,
  });

  final String exerciseId;

  /// Snapshot of the exercise name at session-completion time.
  final String exerciseName;

  final ExerciseType type;
  final List<ActualSet> actualSets;

  @override
  List<Object?> get props => [exerciseId, exerciseName, type, actualSets];
}
