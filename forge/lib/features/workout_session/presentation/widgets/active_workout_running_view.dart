import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:forge/features/workout_session/application/bloc/active_workout_bloc.dart';
import 'package:forge/features/workout_session/application/bloc/active_workout_event.dart';
import 'package:forge/features/workout_session/application/bloc/active_workout_state.dart';
import 'package:forge/features/workout_session/presentation/widgets/active_workout_body.dart';
import 'package:forge/features/workout_session/presentation/widgets/paused_workout_overlay.dart';

/// Owns the set-entry text controllers and re-seeds them with the current
/// exercise's targets whenever the workout moves to another set.
class ActiveWorkoutRunningView extends StatefulWidget {
  const ActiveWorkoutRunningView({required this.state, super.key});

  final ActiveWorkoutRunning state;

  @override
  State<ActiveWorkoutRunningView> createState() =>
      _ActiveWorkoutRunningViewState();
}

class _ActiveWorkoutRunningViewState extends State<ActiveWorkoutRunningView> {
  final _repsController = TextEditingController();
  final _weightController = TextEditingController();
  final _durationController = TextEditingController();

  int? _lastExerciseIndex;
  int? _lastSetIndex;

  @override
  void dispose() {
    _repsController.dispose();
    _weightController.dispose();
    _durationController.dispose();
    super.dispose();
  }

  void _resetControllers(ActiveWorkoutRunning state) {
    final exercise = state.currentExercise;
    _repsController.text = exercise.targetRepetitions?.toString() ?? '';
    _weightController.text = exercise.targetWeight?.toString() ?? '';
    _durationController.text = exercise.targetDurationSec?.toString() ?? '';
  }

  void _syncControllersToPosition(ActiveWorkoutRunning state) {
    final positionChanged =
        state.exerciseIndex != _lastExerciseIndex ||
        state.currentSetIndex != _lastSetIndex;
    if (!positionChanged) return;
    _lastExerciseIndex = state.exerciseIndex;
    _lastSetIndex = state.currentSetIndex;
    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (mounted) _resetControllers(state);
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = widget.state;
    _syncControllersToPosition(state);

    return Stack(
      children: [
        ActiveWorkoutBody(
          state: state,
          repsController: _repsController,
          weightController: _weightController,
          durationController: _durationController,
        ),
        if (state.isPaused)
          PausedWorkoutOverlay(
            onResume: () => context.read<ActiveWorkoutBloc>().add(
              const ActiveWorkoutResumeRequested(),
            ),
            onCancel: () => context.read<ActiveWorkoutBloc>().add(
              const ActiveWorkoutCancelRequested(),
            ),
          ),
      ],
    );
  }
}
