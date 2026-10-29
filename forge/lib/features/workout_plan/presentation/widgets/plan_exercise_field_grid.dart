import 'package:flutter/material.dart';
import 'package:forge/core/theme/app_dimensions.dart';
import 'package:forge/core/enums/exercise_type.dart';
import 'package:forge/features/workout_plan/domain/entities/plan_exercise.dart';
import 'package:forge/l10n/l10n.dart';
import 'package:forge/features/workout_plan/presentation/widgets/plan_field_box.dart';

class PlanExerciseFieldGrid extends StatelessWidget {
  const PlanExerciseFieldGrid({required this.exercise, super.key});

  final PlanExercise exercise;

  @override
  Widget build(BuildContext context) {
    return switch (exercise.type) {
      ExerciseType.weighted => _buildWeighted(context),
      ExerciseType.timeBased => _buildTimeBased(context),
      ExerciseType.bodyweight => _buildBodyweight(context),
    };
  }

  String get _setsValue => '${exercise.targetSets}';

  String _restValue(AppLocalizations l10n) =>
      l10n.planDetailRestValue(exercise.restPeriodSec);

  String _repsValue(AppLocalizations l10n) =>
      '${exercise.targetRepetitions ?? l10n.valueNotAvailable}';

  Widget _buildWeighted(BuildContext context) {
    final l10n = context.l10n;
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: PlanFieldBox(label: l10n.setsLabel, value: _setsValue),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: PlanFieldBox(
                label: l10n.repsLabel,
                value: _repsValue(l10n),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: PlanFieldBox(
                label: l10n.planDetailWeightLabel,
                value: _formatWeight(l10n, exercise.targetWeight),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        PlanFieldBox(label: l10n.planDetailRestLabel, value: _restValue(l10n)),
      ],
    );
  }

  Widget _buildTimeBased(BuildContext context) {
    final l10n = context.l10n;
    return Row(
      children: [
        Expanded(
          child: PlanFieldBox(label: l10n.setsLabel, value: _setsValue),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: PlanFieldBox(
            label: l10n.durationLabel,
            value: _formatDuration(l10n, exercise.targetDurationSec),
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: PlanFieldBox(
            label: l10n.planDetailRestLabel,
            value: _restValue(l10n),
          ),
        ),
      ],
    );
  }

  Widget _buildBodyweight(BuildContext context) {
    final l10n = context.l10n;
    return Row(
      children: [
        Expanded(
          child: PlanFieldBox(label: l10n.setsLabel, value: _setsValue),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: PlanFieldBox(label: l10n.repsLabel, value: _repsValue(l10n)),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: PlanFieldBox(
            label: l10n.planDetailRestLabel,
            value: _restValue(l10n),
          ),
        ),
      ],
    );
  }

  String _formatWeight(AppLocalizations l10n, double? weight) {
    if (weight == null) return l10n.valueNotAvailable;
    final isWhole = weight == weight.truncateToDouble();
    return l10n.weightKgValue(
      isWhole ? '${weight.truncate()}' : weight.toStringAsFixed(1),
    );
  }

  String _formatDuration(AppLocalizations l10n, int? seconds) {
    if (seconds == null) return l10n.valueNotAvailable;
    final mm = (seconds ~/ 60).toString().padLeft(2, '0');
    final ss = (seconds % 60).toString().padLeft(2, '0');
    return '$mm:$ss';
  }
}
