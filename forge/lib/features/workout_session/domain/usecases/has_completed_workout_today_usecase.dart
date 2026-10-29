import 'package:forge/core/exceptions/app_exception.dart';
import 'package:forge/features/workout_session/domain/repositories/workout_session_repository.dart';
import 'package:forge/features/workout_session/domain/rules/completed_today_rule.dart';
import 'package:fpdart/fpdart.dart';

/// Tells whether a plan was already completed today, so starting it again can
/// be confirmed first.
class HasCompletedWorkoutTodayUseCase {
  const HasCompletedWorkoutTodayUseCase(
    this._repository, {
    this.now = DateTime.now,
  });

  final WorkoutSessionRepository _repository;

  /// The clock, replaceable in tests.
  final DateTime Function() now;

  Future<Either<AppException, bool>> call(String planId) async {
    final result = await _repository.getSessionsByPlanId(planId);
    return result.map(
      (sessions) =>
          hasCompletedWorkoutOn(sessions: sessions, planId: planId, day: now()),
    );
  }
}
