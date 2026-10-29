import 'package:forge/core/exceptions/app_exception.dart';
import 'package:forge/features/workout_session/domain/entities/workout_session.dart';
import 'package:forge/features/workout_session/domain/repositories/workout_session_repository.dart';
import 'package:forge/features/workout_session/domain/rules/logged_set_rules.dart';
import 'package:forge/features/workout_session/domain/rules/session_ordering.dart';
import 'package:fpdart/fpdart.dart';

/// Loads every completed session, newest first.
class GetWorkoutHistoryUseCase {
  const GetWorkoutHistoryUseCase(this._repository);

  final WorkoutSessionRepository _repository;

  Future<Either<AppException, List<WorkoutSession>>> call() async {
    final result = await _repository.getAllSessions();
    return result.map(
      (sessions) =>
          sessions.where(isCompletedSession).toList()
            ..sort(compareSessionsNewestFirst),
    );
  }
}
