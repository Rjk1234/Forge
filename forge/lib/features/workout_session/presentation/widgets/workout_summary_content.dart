import 'package:flutter/material.dart';
import 'package:forge/core/theme/app_dimensions.dart';
import 'package:forge/core/utils/format_utils.dart';
import 'package:forge/features/workout_session/domain/entities/workout_session.dart';
import 'package:forge/features/workout_session/presentation/widgets/exercise_breakdown_card.dart';
import 'package:forge/features/workout_session/presentation/widgets/session_stat_row.dart';
import 'package:forge/l10n/l10n.dart';
import 'package:forge/core/theme/app_colors_extension.dart';

/// Scrollable success body: hero, headline stats and per-exercise breakdown.
class WorkoutSummaryContent extends StatelessWidget {
  const WorkoutSummaryContent({required this.session, super.key});

  static const double _horizontalPadding = AppSpacing.lgx;
  static const double _topPadding = AppSpacing.mdl;
  static const double _footerClearance = 90;
  static const double _sectionGap = AppSpacing.lg;
  static const double _statGap = AppSpacing.smd;
  static const double _heroGap = AppSpacing.sm;
  static const double _heroIconWrapSize = 56;
  static const double _heroIconSize = 28;

  final WorkoutSession session;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        _horizontalPadding,
        _topPadding,
        _horizontalPadding,
        _footerClearance,
      ),
      children: [
        _buildHero(context, textTheme),
        const SizedBox(height: _sectionGap),
        SessionStatRow(session: session),
        const SizedBox(height: _sectionGap),
        Text(
          context.l10n.workoutSummaryPerformanceLabel.toUpperCase(),
          style: textTheme.labelLarge,
        ),
        const SizedBox(height: _heroGap),
        for (final exercise in session.sessionExercises) ...[
          ExerciseBreakdownCard(exercise: exercise),
          const SizedBox(height: _statGap),
        ],
      ],
    );
  }

  Widget _buildHero(BuildContext context, TextTheme textTheme) {
    final colorScheme = Theme.of(context).colorScheme;
    final appColors = AppColorsExtension.of(context);
    return Column(
      children: [
        Container(
          width: _heroIconWrapSize,
          height: _heroIconWrapSize,
          decoration: BoxDecoration(
            color: appColors.successContainer,
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.check_rounded,
            size: _heroIconSize,
            color: colorScheme.primary,
          ),
        ),
        const SizedBox(height: _heroGap),
        Text(
          session.planName,
          textAlign: TextAlign.center,
          style: textTheme.headlineLarge,
        ),
        const SizedBox(height: _heroGap / 2),
        Text(
          formatSessionDateTime(session.startedAt),
          style: textTheme.bodyMedium,
        ),
      ],
    );
  }
}
