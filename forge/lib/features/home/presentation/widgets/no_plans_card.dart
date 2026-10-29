import 'package:flutter/material.dart';
import 'package:forge/core/theme/app_dimensions.dart';
import 'package:forge/core/widgets/app_card.dart';
import 'package:forge/core/widgets/app_empty_state.dart';
import 'package:forge/l10n/l10n.dart';

/// Shown in place of today's plan when no workout plan exists yet.
class NoPlansCard extends StatelessWidget {
  const NoPlansCard({required this.onCreatePlan, super.key});

  final VoidCallback onCreatePlan;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return AppCard(
      isFullWidth: true,
      radius: AppRadius.sheet,
      child: AppEmptyState(
        icon: Icons.fitness_center,
        title: l10n.homeEmptyTitle,
        subtitle: l10n.homeEmptySubtitle,
        actionLabel: l10n.homeEmptyCta,
        onAction: onCreatePlan,
        layout: EmptyStateLayout.inline,
      ),
    );
  }
}
