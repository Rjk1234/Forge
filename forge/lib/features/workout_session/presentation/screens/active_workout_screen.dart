import 'package:forge/features/workout_session/presentation/screens/cancel_workout_screen.dart';
import 'package:forge/features/workout_session/presentation/screens/workout_summary_screen.dart';
import 'package:forge/features/workout_session/presentation/screens/rest_timer_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:forge/features/workout_session/application/bloc/active_workout_bloc.dart';
import 'package:forge/features/workout_session/application/bloc/active_workout_event.dart';
import 'package:forge/features/workout_session/application/bloc/active_workout_state.dart';
import 'package:forge/features/workout_session/application/bloc/rest_timer_args.dart';
import 'package:go_router/go_router.dart';
import 'package:forge/features/workout_session/presentation/widgets/active_workout_running_view.dart';

class ActiveWorkoutScreen extends StatelessWidget {
  static const String routePath = '/workout/active';
  static const String routeName = 'activeWorkout';

  const ActiveWorkoutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop && context.mounted) {
          context.read<ActiveWorkoutBloc>().add(
            const ActiveWorkoutCancelRequested(),
          );
        }
      },
      child: BlocConsumer<ActiveWorkoutBloc, ActiveWorkoutState>(
        listener: (context, state) {
          if (state is! ActiveWorkoutRunning) return;
          if (state.navigateToRestTimer) {
            if (!context.mounted) return;
            context.push(
              RestTimerScreen.routePath,
              extra: RestTimerArgs.fromRunning(state),
            );
            context.read<ActiveWorkoutBloc>().add(
              const ActiveWorkoutRestTimerNavigated(),
            );
            return;
          }
          if (state.navigateToPostWorkout && state.completedSession != null) {
            if (!context.mounted) return;
            context.go(
              WorkoutSummaryScreen.routePath,
              extra: state.completedSession,
            );
            context.read<ActiveWorkoutBloc>().add(
              const ActiveWorkoutPostWorkoutNavigated(),
            );
            return;
          }
          if (state.navigateToCancel) {
            if (!context.mounted) return;
            context.push(CancelWorkoutScreen.routePath, extra: state.planName);
            context.read<ActiveWorkoutBloc>().add(
              const ActiveWorkoutCancelNavigated(),
            );
          }
        },
        builder: (context, state) {
          if (state is! ActiveWorkoutRunning) {
            return Scaffold(
              backgroundColor: colorScheme.surfaceContainerLowest,
              body: const SizedBox.shrink(),
            );
          }

          return ActiveWorkoutRunningView(state: state);
        },
      ),
    );
  }
}
