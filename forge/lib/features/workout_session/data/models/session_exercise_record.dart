import 'package:forge/core/enums/exercise_type.dart';
import 'actual_set_record.dart';

/// Actual performance data for one exercise within a completed workout session. Values are copied at session-finish time — not referenced from the plan — so subsequent plan edits cannot change historical data.
class SessionExerciseRecord {
  final String exerciseId;

  /// Snapshot of the exercise name at session-completion time.
  final String exerciseName;

  final ExerciseType type;

  final List<ActualSetRecord> actualSets;

  const SessionExerciseRecord({
    required this.exerciseId,
    required this.exerciseName,
    required this.type,
    required this.actualSets,
  });
}
