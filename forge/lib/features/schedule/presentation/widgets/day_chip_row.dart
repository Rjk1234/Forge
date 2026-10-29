import 'package:flutter/material.dart';
import 'package:forge/core/theme/app_dimensions.dart';

import 'day_chip.dart';
import 'package:forge/l10n/l10n.dart';

/// Assembles 7 [DayChip] entries and, when conflicts are present, an inline
/// conflict-message area below the row.
class DayChipRow extends StatelessWidget {
  const DayChipRow({
    required this.selectedDays,
    required this.conflicts,
    required this.onDayTapped,
    super.key,
  });

  final Set<int> selectedDays;

  /// Weekday → the conflicting plan's name.
  final Map<int, String> conflicts;
  final ValueChanged<int> onDayTapped;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            for (var weekday = 1; weekday <= 7; weekday++) ...[
              if (weekday > 1) const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: DayChip(
                  weekday: weekday,
                  visualState: _visualStateFor(weekday),
                  onTap: () => onDayTapped(weekday),
                ),
              ),
            ],
          ],
        ),
        if (conflicts.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.sm),
          Semantics(
            liveRegion: true,
            child: Text(
              _conflictMessage(context.l10n),
              style: textTheme.bodySmall?.copyWith(color: colorScheme.error),
            ),
          ),
        ],
      ],
    );
  }

  DayChipVisualState _visualStateFor(int weekday) {
    if (conflicts.containsKey(weekday)) return DayChipVisualState.conflict;
    if (selectedDays.contains(weekday)) return DayChipVisualState.selected;
    return DayChipVisualState.unselected;
  }

  String _conflictMessage(AppLocalizations l10n) {
    final entry = conflicts.entries.last;
    final dayName = l10n.weekdayFullNames[entry.key - 1];
    return l10n.scheduleConflictMessage(dayName, entry.value);
  }
}
