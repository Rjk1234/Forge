import 'package:equatable/equatable.dart';
import 'package:forge/features/workout_plan/workout_plan.dart';
import 'package:forge/features/workout_session/application/bloc/active_workout_state.dart';

/// Route payload for the rest timer: the rest duration plus the set that
/// follows it, shown in the "Up Next" card.
class RestTimerArgs extends Equatable {
  const RestTimerArgs({
    required this.restPeriodSec,
    required this.nextExercise,
    required this.nextSetNumber,
  });

  /// Built from a state that has already advanced to the next position.
  factory RestTimerArgs.fromRunning(ActiveWorkoutRunning state) {
    return RestTimerArgs(
      restPeriodSec: state.restPeriodSec,
      nextExercise: state.currentExercise,
      nextSetNumber: state.currentSetIndex + 1,
    );
  }

  final int restPeriodSec;
  final PlanExercise nextExercise;
  final int nextSetNumber;

  @override
  List<Object?> get props => [restPeriodSec, nextExercise, nextSetNumber];
}
