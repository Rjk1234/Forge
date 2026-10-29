import 'package:flutter/material.dart';
import 'package:forge/core/theme/app_dimensions.dart';
import 'package:forge/l10n/l10n.dart';
import 'package:forge/core/theme/app_colors_extension.dart';
import 'package:forge/core/theme/app_text_extension.dart';

/// Save-failure body: the workout is complete but was not persisted yet.
class WorkoutSummaryErrorView extends StatelessWidget {
  const WorkoutSummaryErrorView({
    required this.planName,
    this.isRetryable = true,
    super.key,
  });

  static const double _horizontalPadding = AppSpacing.xxl;
  static const double _gap = AppSpacing.mdl;
  static const double _iconWrapSize = 64;
  static const double _iconSize = 30;

  final String planName;
  final bool isRetryable;

  @override
  Widget build(BuildContext context) {
    final textStyles = AppTextExtension.of(context);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final appColors = AppColorsExtension.of(context);
    final textTheme = theme.textTheme;

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: _horizontalPadding),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: _iconWrapSize,
              height: _iconWrapSize,
              decoration: BoxDecoration(
                color: colorScheme.surface,
                border: Border.all(color: colorScheme.outline),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.event_busy_rounded,
                size: _iconSize,
                color: colorScheme.error,
              ),
            ),
            const SizedBox(height: _gap),
            Text(
              context.l10n.workoutSummaryErrorTitle,
              textAlign: TextAlign.center,
              style: textTheme.titleLarge,
            ),
            const SizedBox(height: _gap),
            Text(
              context.l10n.workoutSummaryErrorPlan(planName),
              textAlign: TextAlign.center,
              style: textStyles.bodyRelaxed,
            ),
            Text(
              isRetryable
                  ? context.l10n.workoutSummaryErrorNote
                  : context.l10n.workoutSummaryInvalidNote,
              textAlign: TextAlign.center,
              style: textTheme.bodyMedium?.copyWith(color: appColors.textDim),
            ),
          ],
        ),
      ),
    );
  }
}
