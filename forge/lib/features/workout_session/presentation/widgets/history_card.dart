import 'package:flutter/material.dart';
import 'package:forge/core/theme/app_dimensions.dart';
import 'package:forge/core/utils/format_utils.dart';
import 'package:forge/features/workout_session/domain/entities/workout_session.dart';
import 'package:forge/l10n/l10n.dart';
import 'package:forge/core/theme/app_colors_extension.dart';

/// One completed session in the history list.
class HistoryCard extends StatelessWidget {
  const HistoryCard({
    required this.dayNumber,
    required this.dayOfWeek,
    required this.planName,
    required this.summaryLine,
    required this.onTap,
    super.key,
  });

  /// Builds a card from [session]; the day badge follows the start date.
  factory HistoryCard.fromSession({
    required WorkoutSession session,
    required AppLocalizations l10n,
    required VoidCallback onTap,
    Key? key,
  }) {
    return HistoryCard(
      key: key,
      dayNumber: session.startedAt.day.toString().padLeft(2, '0'),
      dayOfWeek: formatWeekdayAbbreviation(session.startedAt).toUpperCase(),
      planName: session.planName,
      summaryLine: summaryLineFor(session, l10n),
      onTap: onTap,
    );
  }

  static const double _radius = AppRadius.card;
  static const double _horizontalPadding = AppSpacing.mdl;
  static const double _verticalPadding = AppSpacing.md;
  static const double _gap = AppSpacing.md;
  static const double _badgeWidth = 44;
  static const double _bodyGap = AppSpacing.xxs;
  static const double _chevronSize = 16;

  final String dayNumber;
  final String dayOfWeek;
  final String planName;
  final String summaryLine;
  final VoidCallback onTap;

  /// e.g. "38 min · 5 exercises · 14 sets" (skipped sets are not counted).
  static String summaryLineFor(WorkoutSession session, AppLocalizations l10n) {
    final setCount = session.sessionExercises.fold<int>(
      0,
      (total, exercise) =>
          total + exercise.actualSets.where((set) => !set.skipped).length,
    );
    return l10n.historySummaryLine(
      session.sessionDurationSec ~/ 60,
      session.sessionExercises.length,
      setCount,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final appColors = AppColorsExtension.of(context);
    final textTheme = theme.textTheme;

    return Material(
      color: colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(_radius),
        side: BorderSide(color: colorScheme.outline),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(_radius),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: _horizontalPadding,
            vertical: _verticalPadding,
          ),
          child: Row(
            children: [
              SizedBox(
                width: _badgeWidth,
                child: Column(
                  children: [
                    Text(dayNumber, style: textTheme.titleLarge),
                    Text(
                      dayOfWeek,
                      style: textTheme.labelMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: _gap),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(planName, style: textTheme.titleMedium),
                    const SizedBox(height: _bodyGap),
                    Text(summaryLine, style: textTheme.bodySmall),
                  ],
                ),
              ),
              const SizedBox(width: _gap),
              Icon(
                Icons.chevron_right,
                size: _chevronSize,
                color: appColors.textDim,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
