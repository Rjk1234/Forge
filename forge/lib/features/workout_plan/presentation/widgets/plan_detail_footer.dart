import 'package:flutter/material.dart';
import 'package:forge/core/theme/app_dimensions.dart';
import 'package:forge/l10n/l10n.dart';

class PlanDetailFooter extends StatelessWidget {
  const PlanDetailFooter({
    required this.planId,
    required this.canStart,
    this.shouldShowStartWorkout = true,
    required this.onStartWorkout,
    required this.onSchedule,
    super.key,
  });

  final String planId;
  final bool canStart;

  /// False hides Start Workout (the plan is opened for another day).
  final bool shouldShowStartWorkout;
  final VoidCallback onStartWorkout;
  final VoidCallback onSchedule;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          AppSpacing.md,
          AppSpacing.lg,
          AppSpacing.lg,
        ),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerLowest,
          border: Border(top: BorderSide(color: colorScheme.outline)),
        ),
        child: Row(
          children: [
            if (shouldShowStartWorkout) ...[
              Expanded(
                child: FilledButton(
                  onPressed: canStart ? onStartWorkout : null,
                  child: Text(context.l10n.planDetailStartWorkoutButton),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
            ],
            _scheduleButton(context, textTheme, colorScheme),
          ],
        ),
      ),
    );
  }

  Widget _scheduleButton(
    BuildContext context,
    TextTheme textTheme,
    ColorScheme colorScheme,
  ) {
    final button = OutlinedButton(
      onPressed: onSchedule,
      child: Text(
        context.l10n.planDetailScheduleButton,
        style: textTheme.labelLarge?.copyWith(color: colorScheme.onSurface),
      ),
    );
    return shouldShowStartWorkout ? button : Expanded(child: button);
  }
}
