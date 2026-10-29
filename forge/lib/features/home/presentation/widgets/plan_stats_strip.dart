import 'package:flutter/material.dart';
import 'package:forge/core/theme/app_dimensions.dart';
import 'package:forge/core/utils/format_utils.dart';
import 'package:forge/features/home/domain/entities/today_workout.dart';
import 'package:forge/features/home/presentation/widgets/plan_stat_item.dart';
import 'package:forge/l10n/l10n.dart';

/// Volume, exercise count and total sets of today's plan.
class PlanStatsStrip extends StatelessWidget {
  const PlanStatsStrip({required this.workout, super.key});

  final TodayWorkout workout;

  String _volumeText(AppLocalizations l10n) => workout.plannedVolumeKg > 0
      ? l10n.homeVolumeApprox(formatVolume(workout.plannedVolumeKg))
      : l10n.valueNotAvailable;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(AppRadius.card),
      ),
      child: Row(
        children: [
          PlanStatItem(label: l10n.homeStatVolume, value: _volumeText(l10n)),
          PlanStatItem(
            label: l10n.homeStatExercises,
            value: '${workout.exerciseCount}',
          ),
          PlanStatItem(label: l10n.homeStatSets, value: '${workout.totalSets}'),
        ],
      ),
    );
  }
}
