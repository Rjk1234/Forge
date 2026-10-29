import 'package:forge/core/enums/exercise_type.dart';
import 'package:forge/core/exceptions/app_exception.dart';
import 'package:forge/features/personal_bests/domain/entities/personal_best_record.dart';
import 'package:forge/features/workout_session/domain/entities/actual_set.dart';
import 'package:forge/features/workout_session/domain/entities/workout_session.dart';
import 'package:forge/features/workout_session/domain/repositories/workout_session_repository.dart';
import 'package:forge/features/workout_session/domain/rules/exercise_history.dart';
import 'package:fpdart/fpdart.dart';

/// Finds each exercise's all-time best across stored sessions (read-only).
class GetPersonalBestsUseCase {
  const GetPersonalBestsUseCase(this._repository);

  final WorkoutSessionRepository _repository;

  Future<Either<AppException, List<PersonalBestRecord>>> call() async {
    final result = await _repository.getAllSessions();
    return result.map(_compute);
  }

  List<PersonalBestRecord> _compute(List<WorkoutSession> sessions) {
    final entriesByKey = <(String, ExerciseType), List<ExerciseSessionEntry>>{};
    for (final entries in exerciseHistoryById(sessions).values) {
      for (final entry in entries) {
        entriesByKey
            .putIfAbsent((
              entry.exercise.exerciseId,
              entry.exercise.type,
            ), () => [])
            .add(entry);
      }
    }

    return [for (final entries in entriesByKey.values) _recordFor(entries)]
      ..sort((a, b) => a.exerciseName.compareTo(b.exerciseName));
  }

  /// [entries] are oldest first; on equal values the later session wins and
  /// the most recent snapshot names the exercise.
  PersonalBestRecord _recordFor(List<ExerciseSessionEntry> entries) {
    final type = entries.last.exercise.type;
    var bestValue = 0.0;
    var bestSession = entries.first.session;
    for (final entry in entries) {
      for (final set in entry.exercise.actualSets) {
        final value = _valueOf(set, type);
        if (value >= bestValue) {
          bestValue = value;
          bestSession = entry.session;
        }
      }
    }

    return PersonalBestRecord(
      exerciseName: entries.last.exercise.exerciseName,
      type: type,
      bestDate: bestSession.startedAt,
      bestWeight: type == ExerciseType.weighted ? bestValue : null,
      bestDurationSec: type == ExerciseType.timeBased
          ? bestValue.toInt()
          : null,
      bestReps: type == ExerciseType.bodyweight ? bestValue.toInt() : null,
    );
  }

  double _valueOf(ActualSet set, ExerciseType type) => switch (type) {
    ExerciseType.weighted => set.weight ?? 0,
    ExerciseType.timeBased => (set.durationSec ?? 0).toDouble(),
    ExerciseType.bodyweight => (set.repetitions ?? 0).toDouble(),
  };
}
