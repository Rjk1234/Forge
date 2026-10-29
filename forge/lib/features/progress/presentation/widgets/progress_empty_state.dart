import 'package:flutter/material.dart';
import 'package:forge/core/widgets/app_empty_state.dart';
import 'package:forge/l10n/l10n.dart';

/// Shown when the selected exercise has too little history to compare.
class ProgressEmptyState extends StatelessWidget {
  const ProgressEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return AppEmptyState(
      icon: Icons.trending_up,
      title: l10n.progressEmptyTitle,
      subtitle: l10n.progressEmptySubtitle,
    );
  }
}
