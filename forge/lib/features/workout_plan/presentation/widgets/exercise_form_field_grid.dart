import 'package:flutter/material.dart';
import 'package:forge/core/theme/app_dimensions.dart';
import 'package:flutter/services.dart';
import 'package:forge/core/enums/exercise_type.dart';
import 'package:forge/core/formatters/decimal_one_digit_input_formatter.dart';
import 'package:forge/core/formatters/duration_mm_ss_input_formatter.dart';
import 'package:forge/features/workout_plan/application/bloc/create_edit_workout_plan_event.dart';
import 'package:forge/features/workout_plan/application/bloc/plan_exercise_form_entry.dart';
import 'package:forge/features/workout_plan/presentation/widgets/exercise_field_box.dart';
import 'package:forge/l10n/l10n.dart';

class ExerciseFormFieldGrid extends StatelessWidget {
  const ExerciseFormFieldGrid({
    required this.entry,
    required this.index,
    required this.setsCtrl,
    required this.repsOrDurationCtrl,
    required this.weightCtrl,
    required this.restCtrl,
    required this.onFieldChanged,
    required this.isSaving,
    super.key,
  });

  final PlanExerciseFormEntry entry;
  final int index;
  final TextEditingController setsCtrl;
  final TextEditingController repsOrDurationCtrl;
  final TextEditingController weightCtrl;
  final TextEditingController restCtrl;
  final void Function(int, ExerciseField, String) onFieldChanged;
  final bool isSaving;

  @override
  Widget build(BuildContext context) {
    final isWeighted = entry.type == ExerciseType.weighted;
    final isTimeBased = entry.type == ExerciseType.timeBased;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: ExerciseFieldBox(
            label: context.l10n.setsLabel,
            controller: setsCtrl,
            onChanged: (v) => onFieldChanged(index, ExerciseField.sets, v),
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            hasError: entry.setsError != null,
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(child: _repsOrDurationField(context, isTimeBased)),
        if (isWeighted) ...[
          const SizedBox(width: AppSpacing.sm),
          Expanded(child: _weightField(context)),
        ],
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: ExerciseFieldBox(
            label: context.l10n.restLabel,
            controller: restCtrl,
            onChanged: (v) => onFieldChanged(index, ExerciseField.rest, v),
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            hasError: entry.restError != null,
          ),
        ),
      ],
    );
  }

  Widget _repsOrDurationField(BuildContext context, bool isTimeBased) {
    return ExerciseFieldBox(
      label: isTimeBased ? context.l10n.durationLabel : context.l10n.repsLabel,
      controller: repsOrDurationCtrl,
      onChanged: (v) => onFieldChanged(index, ExerciseField.repsOrDuration, v),
      keyboardType: TextInputType.number,
      inputFormatters: isTimeBased
          ? [DurationMmSsInputFormatter()]
          : [FilteringTextInputFormatter.digitsOnly],
      hasError: entry.repsOrDurationError != null,
    );
  }

  Widget _weightField(BuildContext context) {
    return ExerciseFieldBox(
      label: context.l10n.weightLabel,
      controller: weightCtrl,
      onChanged: (v) => onFieldChanged(index, ExerciseField.weight, v),
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [DecimalOneDigitInputFormatter()],
      hasError: entry.weightError != null,
    );
  }
}
