import 'package:flutter/material.dart';
import 'package:forge/core/widgets/app_empty_state.dart';
import 'package:forge/l10n/l10n.dart';

class HistoryEmptyView extends StatelessWidget {
  const HistoryEmptyView({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return AppEmptyState(
      icon: Icons.history,
      title: l10n.historyEmptyTitle,
      subtitle: l10n.historyEmptySubtitle,
    );
  }
}
