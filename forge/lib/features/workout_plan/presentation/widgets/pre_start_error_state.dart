import 'package:flutter/material.dart';
import 'package:forge/core/widgets/error_card.dart';
import 'package:forge/l10n/l10n.dart';

class PreStartErrorState extends StatelessWidget {
  const PreStartErrorState({required this.onRetry, super.key});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return ErrorCard(
      icon: Icons.cloud_off_rounded,
      title: l10n.preStartErrorTitle,
      message: l10n.preStartErrorBody,
      retryLabel: l10n.preStartRetryButton,
      onRetry: onRetry,
    );
  }
}
