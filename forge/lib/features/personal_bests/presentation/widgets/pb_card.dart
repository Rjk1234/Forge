import 'package:flutter/material.dart';
import 'package:forge/core/theme/app_dimensions.dart';
import 'package:forge/core/widgets/app_card.dart';
import 'package:forge/core/enums/exercise_type.dart';
import 'package:forge/core/utils/format_utils.dart';
import 'package:forge/core/widgets/exercise_type_dot.dart';
import 'package:forge/features/personal_bests/domain/entities/personal_best_record.dart';
import 'package:forge/features/personal_bests/presentation/widgets/pb_badge.dart';
import 'package:forge/l10n/l10n.dart';

/// Read-only row: exercise, the date its best was set, and the best value.
class PbCard extends StatelessWidget {
  const PbCard({required this.record, super.key});

  static const double _radius = AppRadius.card;
  static const double _horizontalPadding = AppSpacing.mdl;
  static const double _verticalPadding = AppSpacing.md;
  static const double _gap = AppSpacing.md;
  static const double _bodyGap = AppSpacing.xxs;

  final PersonalBestRecord record;

  String _dateText(AppLocalizations l10n) =>
      l10n.pbDateSet(formatShortDate(record.bestDate));

  String _badgeValue(AppLocalizations l10n) => switch (record.type) {
    ExerciseType.weighted =>
      '${formatWeightValue(record.bestWeight ?? 0)} ${l10n.pbWeightUnit}',
    ExerciseType.timeBased => formatDuration(record.bestDurationSec ?? 0),
    ExerciseType.bodyweight => '${record.bestReps ?? 0} ${l10n.pbRepsUnit}',
  };

  String _badgeLabel(AppLocalizations l10n) => switch (record.type) {
    ExerciseType.weighted => l10n.pbBadgeWeightLabel,
    ExerciseType.timeBased => l10n.pbBadgeTimeLabel,
    ExerciseType.bodyweight => l10n.pbBadgeRepsLabel,
  };

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return AppCard(
      radius: _radius,
      padding: const EdgeInsets.symmetric(
        horizontal: _horizontalPadding,
        vertical: _verticalPadding,
      ),
      child: Row(
        children: [
          ExerciseTypeDot(type: record.type),
          const SizedBox(width: _gap),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  record.exerciseName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.titleMedium,
                ),
                const SizedBox(height: _bodyGap),
                Text(_dateText(context.l10n), style: textTheme.bodySmall),
              ],
            ),
          ),
          const SizedBox(width: _gap),
          PbBadge(
            value: _badgeValue(context.l10n),
            label: _badgeLabel(context.l10n),
          ),
        ],
      ),
    );
  }
}
