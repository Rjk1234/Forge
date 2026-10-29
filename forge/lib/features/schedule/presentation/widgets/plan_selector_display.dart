import 'package:flutter/material.dart';
import 'package:forge/core/theme/app_dimensions.dart';
import 'package:forge/core/widgets/app_card.dart';
import 'package:forge/l10n/l10n.dart';

/// Static, non-tappable plan-name card — no in-screen plan picker.
class PlanSelectorDisplay extends StatelessWidget {
  const PlanSelectorDisplay({required this.planName, super.key});

  final String planName;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Semantics(
      label: '${context.l10n.workoutPlanSemanticsPrefix}$planName',
      child: AppCard(
        isFullWidth: true,
        radius: 12,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.mdl,
          vertical: 13,
        ),
        child: Text(
          planName,
          style: textTheme.bodyLarge?.copyWith(color: colorScheme.onSurface),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }
}
