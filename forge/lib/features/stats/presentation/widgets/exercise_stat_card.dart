import 'package:flutter/material.dart';
import 'package:forge/core/theme/app_dimensions.dart';
import 'package:forge/core/widgets/app_card.dart';
import 'package:forge/core/enums/exercise_type.dart';
import 'package:forge/core/utils/format_utils.dart';
import 'package:forge/core/widgets/exercise_type_dot.dart';
import 'package:forge/features/stats/domain/entities/exercise_stat_row.dart';
import 'package:forge/l10n/l10n.dart';
import 'package:forge/core/theme/app_text_extension.dart';

/// Read-only breakdown row: session count and the best value for the type.
class ExerciseStatCard extends StatelessWidget {
  const ExerciseStatCard({required this.row, super.key});

  static const double _radius = AppRadius.card;
  static const double _horizontalPadding = AppSpacing.mdl;
  static const double _verticalPadding = AppSpacing.md;
  static const double _gap = AppSpacing.md;
  static const double _bodyGap = AppSpacing.xxs;

  final ExerciseStatRow row;

  String _sessionsText(AppLocalizations l10n) =>
      l10n.sessionCount(row.sessionCount);

  String _bestValue(AppLocalizations l10n) => switch (row.type) {
    ExerciseType.weighted =>
      '${formatWeightValue(row.bestWeight)} ${l10n.statsVolumeUnit}',
    ExerciseType.timeBased => formatDuration(row.bestDurationSec),
    ExerciseType.bodyweight => '${row.bestReps}',
  };

  String _bestLabel(AppLocalizations l10n) => switch (row.type) {
    ExerciseType.weighted => l10n.statsBestWeight,
    ExerciseType.timeBased => l10n.statsBestTime,
    ExerciseType.bodyweight => l10n.statsBestReps,
  };

  @override
  Widget build(BuildContext context) {
    final textStyles = AppTextExtension.of(context);
    final textTheme = Theme.of(context).textTheme;

    return AppCard(
      radius: _radius,
      padding: const EdgeInsets.symmetric(
        horizontal: _horizontalPadding,
        vertical: _verticalPadding,
      ),
      child: Row(
        children: [
          ExerciseTypeDot(type: row.type),
          const SizedBox(width: _gap),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  row.exerciseName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.titleSmall,
                ),
                const SizedBox(height: _bodyGap),
                Text(_sessionsText(context.l10n), style: textTheme.bodySmall),
              ],
            ),
          ),
          const SizedBox(width: _gap),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(_bestValue(context.l10n), style: textStyles.valueSmall),
              Text(_bestLabel(context.l10n), style: textTheme.labelMedium),
            ],
          ),
        ],
      ),
    );
  }
}
