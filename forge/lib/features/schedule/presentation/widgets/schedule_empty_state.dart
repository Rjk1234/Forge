import 'package:flutter/material.dart';
import 'package:forge/core/widgets/app_empty_state.dart';
import 'package:forge/l10n/l10n.dart';

class ScheduleEmptyState extends StatelessWidget {
  const ScheduleEmptyState({required this.onScheduleTap, super.key});

  final VoidCallback onScheduleTap;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return AppEmptyState(
      icon: Icons.calendar_month_outlined,
      title: l10n.scheduleEmptyTitle,
      subtitle: l10n.scheduleEmptySubtitle,
      actionLabel: l10n.scheduleEmptyCta,
      onAction: onScheduleTap,
    );
  }
}
