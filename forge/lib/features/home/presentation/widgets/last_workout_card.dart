import 'package:flutter/material.dart';
import 'package:forge/core/theme/app_dimensions.dart';
import 'package:forge/core/utils/format_utils.dart';
import 'package:forge/core/widgets/app_card.dart';
import 'package:forge/features/home/domain/entities/last_workout.dart';
import 'package:forge/l10n/l10n.dart';

/// Recap of the most recent completed workout; tapping opens its details.
class LastWorkoutCard extends StatelessWidget {
  const LastWorkoutCard({
    required this.workout,
    required this.onTap,
    super.key,
  });

  static const int _secondsPerMinute = 60;

  final LastWorkout workout;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.sheet),
      child: AppCard(
        isFullWidth: true,
        radius: AppRadius.sheet,
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.homeLastWorkout,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    workout.planName,
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    l10n.homeLastWorkoutDetails(
                      formatMonthDay(workout.completedAt),
                      workout.durationSec ~/ _secondsPerMinute,
                      formatVolume(workout.volumeKg),
                    ),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: colorScheme.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }
}
