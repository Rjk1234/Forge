import 'package:forge/core/enums/exercise_type.dart';

/// Developer-seeded exercise catalogue entry, keyed by [id]. Read-only from the client — never created or edited by the user.
class ExerciseRecord {
  /// Stable string identifier (e.g. 'ex_bench_press')
  final String id;

  final String name;

  /// Determines which target/actual fields are shown and stored.
  final ExerciseType type;

  final String? muscleGroup;

  final String? description;

  const ExerciseRecord({
    required this.id,
    required this.name,
    required this.type,
    this.muscleGroup,
    this.description,
  });
}
