import 'package:flutter/material.dart';
import 'package:forge/core/theme/app_dimensions.dart';
import 'package:forge/features/workout_session/domain/entities/workout_session.dart';
import 'package:forge/features/workout_session/presentation/widgets/summary_stat_box.dart';
import 'package:forge/l10n/l10n.dart';

/// Duration, exercise count and logged-set count of a completed session.
class SessionStatRow extends StatelessWidget {
  const SessionStatRow({required this.session, super.key});

  static const double _gap = AppSpacing.smd;

  final WorkoutSession session;

  int get _loggedSetCount => session.sessionExercises.fold(
    0,
    (total, exercise) =>
        total + exercise.actualSets.where((set) => !set.skipped).length,
  );

  String _durationLabel(AppLocalizations l10n) =>
      '${session.sessionDurationSec ~/ 60} '
      '${l10n.workoutSummaryDurationSuffix}';

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: SummaryStatBox(
            label: context.l10n.workoutSummaryDurationLabel,
            value: _durationLabel(context.l10n),
          ),
        ),
        const SizedBox(width: _gap),
        Expanded(
          child: SummaryStatBox(
            label: context.l10n.workoutSummaryExercisesLabel,
            value: '${session.sessionExercises.length}',
          ),
        ),
        const SizedBox(width: _gap),
        Expanded(
          child: SummaryStatBox(
            label: context.l10n.workoutSummarySetsLoggedLabel,
            value: '$_loggedSetCount',
          ),
        ),
      ],
    );
  }
}
