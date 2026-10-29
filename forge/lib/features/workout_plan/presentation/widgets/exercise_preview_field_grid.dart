import 'package:flutter/material.dart';
import 'package:forge/core/theme/app_dimensions.dart';
import 'package:forge/core/enums/exercise_type.dart';
import 'package:forge/core/utils/format_utils.dart';
import 'package:forge/features/workout_plan/domain/entities/plan_exercise.dart';
import 'package:forge/l10n/l10n.dart';
import 'package:forge/features/workout_plan/presentation/widgets/preview_field_box.dart';

class ExercisePreviewFieldGrid extends StatelessWidget {
  const ExercisePreviewFieldGrid({required this.exercise, super.key});

  final PlanExercise exercise;

  @override
  Widget build(BuildContext context) {
    final fields = _fields(context);

    return Row(
      children: [
        for (var i = 0; i < fields.length; i++) ...[
          if (i > 0) const SizedBox(width: AppSpacing.sm),
          Expanded(child: fields[i]),
        ],
      ],
    );
  }

  List<PreviewFieldBox> _fields(BuildContext context) {
    final l10n = context.l10n;
    final setsField = PreviewFieldBox(
      label: l10n.setsLabel,
      value: '${exercise.targetSets}',
    );
    final repsField = PreviewFieldBox(
      label: l10n.repsLabel,
      value: '${exercise.targetRepetitions ?? l10n.preStartWeightNotSet}',
    );

    return switch (exercise.type) {
      ExerciseType.weighted => [
        setsField,
        repsField,
        PreviewFieldBox(
          label: l10n.weightLabel,
          value: _weightValue(l10n, exercise.targetWeight),
        ),
      ],
      ExerciseType.timeBased => [
        setsField,
        PreviewFieldBox(
          label: l10n.durationLabel,
          value: exercise.targetDurationSec != null
              ? formatDuration(exercise.targetDurationSec!)
              : l10n.preStartWeightNotSet,
        ),
      ],
      ExerciseType.bodyweight => [setsField, repsField],
    };
  }

  String _weightValue(AppLocalizations l10n, double? weight) {
    if (weight == null || weight == 0) return l10n.preStartWeightNotSet;
    final isWhole = weight == weight.truncateToDouble();
    return isWhole ? '${weight.truncate()}' : weight.toStringAsFixed(1);
  }
}
