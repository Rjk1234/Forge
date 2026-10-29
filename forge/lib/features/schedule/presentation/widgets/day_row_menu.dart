import 'package:flutter/material.dart';
import 'package:forge/l10n/l10n.dart';

enum DayRowAction { changeDays, remove }

/// Overflow menu of a scheduled day: change its days or remove it.
class DayRowMenu extends StatelessWidget {
  const DayRowMenu({
    required this.onChangeDays,
    required this.onRemove,
    super.key,
  });

  final VoidCallback onChangeDays;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colorScheme = Theme.of(context).colorScheme;

    return PopupMenuButton<DayRowAction>(
      tooltip: l10n.scheduleRowMenuTooltip,
      icon: Icon(Icons.more_vert, color: colorScheme.onSurfaceVariant),
      color: colorScheme.surface,
      onSelected: (action) => switch (action) {
        DayRowAction.changeDays => onChangeDays(),
        DayRowAction.remove => onRemove(),
      },
      itemBuilder: (context) => [
        PopupMenuItem(
          value: DayRowAction.changeDays,
          child: Text(l10n.scheduleChangeDaysAction),
        ),
        PopupMenuItem(
          value: DayRowAction.remove,
          child: Text(
            l10n.scheduleRemoveAction,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: colorScheme.error),
          ),
        ),
      ],
    );
  }
}
