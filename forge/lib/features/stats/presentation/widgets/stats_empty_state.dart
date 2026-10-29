import 'package:flutter/material.dart';
import 'package:forge/core/widgets/app_empty_state.dart';
import 'package:forge/l10n/l10n.dart';

/// Prompt shown under the dimmed tiles when no workout has been completed.
class StatsEmptyState extends StatelessWidget {
  const StatsEmptyState({required this.onStartWorkout, super.key});

  final VoidCallback onStartWorkout;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return AppEmptyState(
      icon: Icons.bar_chart,
      title: l10n.statsEmptyTitle,
      subtitle: l10n.statsEmptySub,
      actionLabel: l10n.statsEmptyCta,
      onAction: onStartWorkout,
      layout: EmptyStateLayout.inline,
    );
  }
}
