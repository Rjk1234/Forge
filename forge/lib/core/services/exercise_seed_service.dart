import '../database/exercise_seed_data.dart';
import '../../features/exercise/data/datasources/exercise_local_data_source.dart';

/// Keeps the exercise catalogue box in step with the bundled seed data.
///
/// Runs on every launch. The catalogue is developer-owned and read-only, so
/// replacing it is safe: fresh installs get populated, new exercises reach
/// existing installs, and unreadable leftovers from older builds are dropped.
class ExerciseSeedService {
  final ExerciseLocalDataSource _dataSource;

  ExerciseSeedService({required this._dataSource});

  Future<void> syncCatalogue() => _dataSource.seedExercises(exerciseSeedData);
}
