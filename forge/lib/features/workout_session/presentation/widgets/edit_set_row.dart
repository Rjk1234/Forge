import 'package:flutter/material.dart';
import 'package:forge/core/theme/app_dimensions.dart';
import 'package:flutter/services.dart';
import 'package:forge/core/enums/exercise_type.dart';
import 'package:forge/core/formatters/decimal_one_digit_input_formatter.dart';
import 'package:forge/core/validation/workout_value_rules.dart';
import 'package:forge/features/workout_plan/presentation/widgets/exercise_field_box.dart';
import 'package:forge/features/workout_session/application/models/edit_set_entry.dart';
import 'package:forge/features/workout_session/application/models/edit_set_mapping.dart';
import 'package:forge/l10n/l10n.dart';

/// One editable set: the fields its exercise type needs, plus a Skipped switch.
class EditSetRow extends StatefulWidget {
  const EditSetRow({
    required this.setNumber,
    required this.type,
    required this.entry,
    required this.onFieldChanged,
    required this.onSkippedChanged,
    super.key,
  });

  final int setNumber;
  final ExerciseType type;
  final EditSetEntry entry;
  final void Function(EditSetField field, String value) onFieldChanged;
  final ValueChanged<bool> onSkippedChanged;

  @override
  State<EditSetRow> createState() => _EditSetRowState();
}

class _EditSetRowState extends State<EditSetRow> {
  static const double _fieldGap = AppSpacing.md;
  static const double _gap = AppSpacing.sm;

  late final Map<EditSetField, TextEditingController> _controllers = {
    for (final field in fieldsFor(widget.type))
      field: TextEditingController(text: widget.entry.textOf(field)),
  };

  @override
  void dispose() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  String? _errorFor(AppLocalizations l10n, EditSetField field) {
    if (!widget.entry.invalidFields.contains(field)) return null;
    return switch (field) {
      EditSetField.reps => l10n.activeWorkoutRepsError(
        WorkoutLimits.maxRepetitions,
      ),
      EditSetField.weight => l10n.activeWorkoutWeightError(
        WorkoutLimits.maxWeightKg.toInt(),
      ),
      EditSetField.duration => l10n.activeWorkoutDurationError(
        WorkoutLimits.maxDurationSec,
      ),
    };
  }

  String _labelFor(AppLocalizations l10n, EditSetField field) =>
      switch (field) {
        EditSetField.reps => l10n.activeWorkoutRepsLabel,
        EditSetField.weight => l10n.activeWorkoutWeightLabel,
        EditSetField.duration => l10n.activeWorkoutDurationLabel,
      };

  Widget _buildField(AppLocalizations l10n, EditSetField field) {
    final isWeight = field == EditSetField.weight;
    final error = _errorFor(l10n, field);
    return Expanded(
      child: ExerciseFieldBox(
        label: _labelFor(l10n, field),
        controller: _controllers[field]!,
        onChanged: (value) => widget.onFieldChanged(field, value),
        keyboardType: TextInputType.numberWithOptions(decimal: isWeight),
        inputFormatters: [
          if (isWeight)
            DecimalOneDigitInputFormatter()
          else
            FilteringTextInputFormatter.digitsOnly,
        ],
        hasError: error != null,
        errorText: error,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final textTheme = Theme.of(context).textTheme;
    final fields = fieldsFor(widget.type);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                l10n.editSessionSetLabel(widget.setNumber),
                style: textTheme.labelLarge,
              ),
            ),
            Text(l10n.editSessionSkippedLabel, style: textTheme.labelMedium),
            const SizedBox(width: _gap),
            Switch(
              value: widget.entry.skipped,
              onChanged: widget.onSkippedChanged,
            ),
          ],
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (var i = 0; i < fields.length; i++) ...[
              if (i > 0) const SizedBox(width: _fieldGap),
              _buildField(l10n, fields[i]),
            ],
          ],
        ),
      ],
    );
  }
}
