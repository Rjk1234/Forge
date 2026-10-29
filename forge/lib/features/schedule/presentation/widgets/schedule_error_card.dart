import 'package:flutter/material.dart';
import 'package:forge/core/widgets/error_card.dart';
import 'package:forge/l10n/l10n.dart';

class ScheduleErrorCard extends StatelessWidget {
  const ScheduleErrorCard({required this.onRetry, super.key});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return ErrorCard(
      icon: Icons.warning_amber_rounded,
      title: l10n.scheduleErrorTitle,
      message: l10n.scheduleErrorReassurance,
      retryLabel: l10n.scheduleRetryButton,
      onRetry: onRetry,
    );
  }
}
