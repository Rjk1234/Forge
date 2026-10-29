import 'package:flutter/material.dart';
import 'package:forge/l10n/l10n.dart';

enum DayChipVisualState { unselected, selected, conflict }

/// Single circular day chip — unselected / selected / conflict tri-state.
class DayChip extends StatelessWidget {
  const DayChip({
    required this.weekday,
    required this.visualState,
    required this.onTap,
    super.key,
  });

  /// ISO weekday: 1=Monday … 7=Sunday.
  final int weekday;
  final DayChipVisualState visualState;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final (background, border, textColor) = switch (visualState) {
      DayChipVisualState.unselected => (
        colorScheme.surface,
        colorScheme.outline,
        colorScheme.onSurfaceVariant,
      ),
      DayChipVisualState.selected => (
        colorScheme.primary,
        colorScheme.primary,
        colorScheme.onPrimary,
      ),
      DayChipVisualState.conflict => (
        colorScheme.errorContainer,
        colorScheme.error,
        colorScheme.error,
      ),
    };

    return Semantics(
      label: _semanticsLabel(context.l10n),
      button: true,
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
          child: AspectRatio(
            aspectRatio: 1,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: background,
                shape: BoxShape.circle,
                border: Border.all(color: border),
              ),
              child: Center(
                child: Text(
                  context.l10n.weekdayAbbreviations[weekday - 1][0],
                  style: textTheme.labelMedium?.copyWith(color: textColor),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _semanticsLabel(AppLocalizations l10n) {
    final dayName = l10n.weekdayFullNames[weekday - 1];
    return switch (visualState) {
      DayChipVisualState.unselected => l10n.dayChipNotSelected(dayName),
      DayChipVisualState.selected => l10n.dayChipSelected(dayName),
      DayChipVisualState.conflict => l10n.dayChipUnavailable(dayName),
    };
  }
}
