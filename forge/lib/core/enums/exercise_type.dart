/// Describes how an exercise is performed and which fields are applicable.
/// - [weighted]  → targetSets + targetRepetitions + targetWeight
/// - [timeBased] → targetSets + targetDurationSec (stored in seconds, shown mm:ss)
/// - [bodyweight] → targetSets + targetRepetitions (no weight field)
enum ExerciseType { weighted, timeBased, bodyweight }
