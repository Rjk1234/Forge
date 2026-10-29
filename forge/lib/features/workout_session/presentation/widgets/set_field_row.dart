import 'package:flutter/material.dart';
import 'package:forge/core/theme/app_dimensions.dart';
import 'package:flutter/services.dart';
import 'package:forge/core/enums/exercise_type.dart';
import 'package:forge/core/formatters/decimal_one_digit_input_formatter.dart';
import 'package:forge/core/validation/workout_value_rules.dart';
import 'package:forge/features/workout_plan/presentation/widgets/exercise_field_box.dart';
import 'package:forge/features/workout_session/application/bloc/active_workout_event.dart';
import 'package:forge/features/workout_session/application/bloc/active_workout_state.dart';
import 'package:forge/l10n/l10n.dart';

class SetFieldRow extends StatelessWidget {
  const SetFieldRow({
    required this.type,
    required this.repsController,
    required this.weightController,
    required this.durationController,
    required this.onCompleteSet,
    required this.onSkip,
    this.repError,
    this.weightError,
    this.durationError,
    this.onFieldChanged,
    super.key,
  });

  final ExerciseType type;
  final TextEditingController repsController;
  final TextEditingController weightController;
  final TextEditingController durationController;
  final ActiveWorkoutFieldError? repError;
  final ActiveWorkoutFieldError? weightError;
  final ActiveWorkoutFieldError? durationError;
  final VoidCallback onCompleteSet;
  final VoidCallback onSkip;
  final ValueChanged<(ActiveWorkoutField, String)>? onFieldChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildFields(context.l10n),
        const SizedBox(height: AppSpacing.lg),
        FilledButton(
          onPressed: onCompleteSet,
          style: FilledButton.styleFrom(backgroundColor: colorScheme.primary),
          child: Text(
            context.l10n.activeWorkoutCompleteSetButton,
            style: textTheme.labelLarge?.copyWith(color: colorScheme.onPrimary),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        TextButton(
          onPressed: onSkip,
          child: Text(
            context.l10n.activeWorkoutSkipButton,
            style: textTheme.labelLarge?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ],
    );
  }

  String? _messageFor(AppLocalizations l10n, ActiveWorkoutFieldError? error) {
    return switch (error) {
      null => null,
      ActiveWorkoutFieldError.repsNotPositive => l10n.activeWorkoutRepsError(
        WorkoutLimits.maxRepetitions,
      ),
      ActiveWorkoutFieldError.weightInvalid => l10n.activeWorkoutWeightError(
        WorkoutLimits.maxWeightKg.toInt(),
      ),
      ActiveWorkoutFieldError.durationNotPositive =>
        l10n.activeWorkoutDurationError(WorkoutLimits.maxDurationSec),
    };
  }

  Widget _buildFields(AppLocalizations l10n) {
    return switch (type) {
      ExerciseType.weighted => Row(
        children: [
          Expanded(
            child: ExerciseFieldBox(
              label: l10n.activeWorkoutRepsLabel,
              controller: repsController,
              onChanged: (v) =>
                  onFieldChanged?.call((ActiveWorkoutField.reps, v)),
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              hasError: repError != null,
              errorText: _messageFor(l10n, repError),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: ExerciseFieldBox(
              label: l10n.activeWorkoutWeightLabel,
              controller: weightController,
              onChanged: (v) =>
                  onFieldChanged?.call((ActiveWorkoutField.weight, v)),
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              inputFormatters: [DecimalOneDigitInputFormatter()],
              hasError: weightError != null,
              errorText: _messageFor(l10n, weightError),
            ),
          ),
        ],
      ),
      ExerciseType.bodyweight => ExerciseFieldBox(
        label: l10n.activeWorkoutRepsLabel,
        controller: repsController,
        onChanged: (v) => onFieldChanged?.call((ActiveWorkoutField.reps, v)),
        keyboardType: TextInputType.number,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        hasError: repError != null,
        errorText: _messageFor(l10n, repError),
      ),
      ExerciseType.timeBased => ExerciseFieldBox(
        label: l10n.activeWorkoutDurationLabel,
        controller: durationController,
        onChanged: (v) =>
            onFieldChanged?.call((ActiveWorkoutField.duration, v)),
        keyboardType: TextInputType.number,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        hasError: durationError != null,
        errorText: _messageFor(l10n, durationError),
      ),
    };
  }
}
