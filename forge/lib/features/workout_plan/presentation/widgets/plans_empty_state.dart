import 'package:flutter/material.dart';
import 'package:forge/core/widgets/app_empty_state.dart';
import 'package:forge/l10n/l10n.dart';

class PlansEmptyState extends StatelessWidget {
  const PlansEmptyState({required this.onCreateTap, super.key});

  final VoidCallback onCreateTap;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return AppEmptyState(
      icon: Icons.list_alt_outlined,
      title: l10n.plansEmptyTitle,
      subtitle: l10n.plansEmptySubtitle,
      actionLabel: l10n.plansEmptyCta,
      onAction: onCreateTap,
    );
  }
}
