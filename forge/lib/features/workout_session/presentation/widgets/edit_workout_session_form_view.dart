import 'package:flutter/material.dart';
import 'package:forge/core/theme/app_dimensions.dart';
import 'package:forge/core/widgets/full_width.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:forge/core/widgets/status_banner.dart';
import 'package:forge/features/workout_session/application/bloc/edit_workout_session_bloc.dart';
import 'package:forge/features/workout_session/application/bloc/edit_workout_session_event.dart';
import 'package:forge/features/workout_session/application/bloc/edit_workout_session_state.dart';
import 'package:forge/features/workout_session/presentation/widgets/edit_exercise_section.dart';
import 'package:forge/l10n/l10n.dart';

/// The editable exercises of a logged workout with the Save / Retry button.
class EditWorkoutSessionFormView extends StatelessWidget {
  const EditWorkoutSessionFormView({required this.state, super.key});

  static const double _horizontalPadding = AppSpacing.lgx;
  static const double _verticalPadding = AppSpacing.mdl;
  static const double _gap = AppSpacing.smd;

  final EditWorkoutSessionEditable state;

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<EditWorkoutSessionBloc>();
    return Column(
      children: [
        Expanded(child: _buildExerciseList(context, bloc)),
        _buildSaveButton(context, bloc),
      ],
    );
  }

  Widget _buildExerciseList(BuildContext context, EditWorkoutSessionBloc bloc) {
    final current = state;
    final l10n = context.l10n;
    final hasNoValidSet =
        current is EditWorkoutSessionReady && current.hasNoValidSet;

    return ListView(
      padding: const EdgeInsets.symmetric(
        horizontal: _horizontalPadding,
        vertical: _verticalPadding,
      ),
      children: [
        for (var i = 0; i < current.exercises.length; i++) ...[
          EditExerciseSection(
            key: ValueKey('exercise-$i'),
            exercise: current.exercises[i],
            onFieldChanged: (setIndex, field, value) => bloc.add(
              EditWorkoutSessionFieldChanged(
                exerciseIndex: i,
                setIndex: setIndex,
                field: field,
                value: value,
              ),
            ),
            onSkippedChanged: (setIndex, skipped) => bloc.add(
              EditWorkoutSessionSkipToggled(
                exerciseIndex: i,
                setIndex: setIndex,
                skipped: skipped,
              ),
            ),
          ),
          const SizedBox(height: _gap),
        ],
        if (hasNoValidSet)
          StatusBanner(message: l10n.editSessionNoValidSetError),
        if (state is EditWorkoutSessionSaveFailure)
          StatusBanner(message: l10n.editSessionSaveError),
      ],
    );
  }

  Widget _buildSaveButton(BuildContext context, EditWorkoutSessionBloc bloc) {
    final l10n = context.l10n;
    final isSaving = state is EditWorkoutSessionSaving;
    final label = switch (state) {
      EditWorkoutSessionSaving() => l10n.editSessionSavingLabel,
      EditWorkoutSessionSaveFailure() => l10n.editSessionRetryButton,
      _ => l10n.editSessionSaveButton,
    };

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: _horizontalPadding,
          vertical: _verticalPadding,
        ),
        child: FullWidth(
          child: FilledButton(
            onPressed: isSaving
                ? null
                : () => bloc.add(const EditWorkoutSessionSaveRequested()),
            child: Text(label),
          ),
        ),
      ),
    );
  }
}
