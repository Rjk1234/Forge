import 'package:flutter/material.dart';
import 'package:forge/core/theme/app_dimensions.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:forge/features/workout_session/application/bloc/active_workout_bloc.dart';
import 'package:forge/features/workout_session/application/bloc/active_workout_event.dart';
import 'package:forge/features/workout_session/application/bloc/active_workout_state.dart';
import 'package:forge/features/workout_session/presentation/widgets/set_field_row.dart';
import 'package:forge/features/workout_session/presentation/widgets/set_progress_row.dart';
import 'package:forge/l10n/l10n.dart';

class ActiveWorkoutBody extends StatelessWidget {
  const ActiveWorkoutBody({
    required this.state,
    required this.repsController,
    required this.weightController,
    required this.durationController,
    super.key,
  });

  final ActiveWorkoutRunning state;
  final TextEditingController repsController;
  final TextEditingController weightController;
  final TextEditingController durationController;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final bloc = context.read<ActiveWorkoutBloc>();

    return Scaffold(
      backgroundColor: colorScheme.surfaceContainerLowest,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.xl,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ..._buildHeader(context, textTheme, colorScheme),
              const SizedBox(height: AppSpacing.lg),
              SetProgressRow(
                statuses: state.setStatuses,
                currentSetIndex: state.currentSetIndex,
              ),
              const SizedBox(height: AppSpacing.xl),
              _buildSetFields(bloc),
              const SizedBox(height: AppSpacing.xl),
              _buildActionButtons(context, bloc, textTheme, colorScheme),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildHeader(
    BuildContext context,
    TextTheme textTheme,
    ColorScheme colorScheme,
  ) {
    return [
      Text(
        context.l10n.activeWorkoutExerciseOf(
          state.exerciseIndex + 1,
          state.exerciseCount,
        ),
        style: textTheme.labelMedium?.copyWith(
          color: colorScheme.onSurfaceVariant,
        ),
      ),
      const SizedBox(height: AppSpacing.sm),
      Text(
        state.currentExercise.exerciseName,
        style: textTheme.headlineSmall?.copyWith(color: colorScheme.onSurface),
        softWrap: true,
      ),
      const SizedBox(height: AppSpacing.xs),
      Text(
        context.l10n.activeWorkoutSetOf(
          state.currentSetIndex + 1,
          state.setStatuses.length,
        ),
        style: textTheme.labelSmall?.copyWith(
          color: colorScheme.onSurfaceVariant,
        ),
      ),
    ];
  }

  Widget _buildSetFields(ActiveWorkoutBloc bloc) {
    return SetFieldRow(
      type: state.currentExercise.type,
      repsController: repsController,
      weightController: weightController,
      durationController: durationController,
      repError: state.repError,
      weightError: state.weightError,
      durationError: state.durationError,
      onCompleteSet:
          state.repError == null &&
              state.weightError == null &&
              state.durationError == null
          ? () => bloc.add(
              ActiveWorkoutCompleteSetRequested(
                reps: int.tryParse(repsController.text),
                weight: double.tryParse(weightController.text),
                durationSec: int.tryParse(durationController.text),
              ),
            )
          : () {},
      onSkip: () => bloc.add(const ActiveWorkoutSkipSetRequested()),
      onFieldChanged: (record) {
        final (field, value) = record;
        bloc.add(ActiveWorkoutFieldChanged(field: field, value: value));
      },
    );
  }

  Widget _buildActionButtons(
    BuildContext context,
    ActiveWorkoutBloc bloc,
    TextTheme textTheme,
    ColorScheme colorScheme,
  ) {
    return Row(
      children: [
        Expanded(
          child: TextButton(
            onPressed: () => bloc.add(const ActiveWorkoutCancelRequested()),
            child: Text(
              context.l10n.activeWorkoutCancelButton,
              style: textTheme.labelLarge?.copyWith(color: colorScheme.error),
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: TextButton(
            onPressed: () => bloc.add(const ActiveWorkoutPauseRequested()),
            child: Text(
              context.l10n.activeWorkoutPauseButton,
              style: textTheme.labelLarge?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
