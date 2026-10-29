import 'package:flutter/material.dart';
import 'package:forge/core/widgets/app_empty_state.dart';
import 'package:forge/l10n/l10n.dart';

class PbEmptyState extends StatelessWidget {
  const PbEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return AppEmptyState(
      icon: Icons.emoji_events_outlined,
      title: l10n.pbEmptyTitle,
      subtitle: l10n.pbEmptySubtitle,
    );
  }
}
