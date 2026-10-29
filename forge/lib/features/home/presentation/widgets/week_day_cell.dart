import 'package:flutter/material.dart';
import 'package:forge/core/theme/app_dimensions.dart';
import 'package:forge/features/home/domain/entities/week_day_status.dart';
import 'package:forge/l10n/l10n.dart';

/// One day of the week strip: its letter and a marker for its state.
class WeekDayCell extends StatelessWidget {
  const WeekDayCell({
    required this.day,
    required this.label,
    required this.isSelected,
    required this.onTap,
    super.key,
  });

  static const double _markerSize = 28;
  static const double _emphasizedBorderWidth = 1.5;

  final WeekDayStatus day;
  final String label;

  /// The day whose details are shown under the strip.
  final bool isSelected;
  final VoidCallback onTap;

  String _statusText(AppLocalizations l10n) => switch (day.state) {
    WeekDayState.completed => l10n.homeWeekDayCompleted,
    WeekDayState.planned => l10n.homeWeekDayPlanned,
    WeekDayState.missed => l10n.homeWeekDayMissed,
    WeekDayState.rest => l10n.homeWeekDayRest,
  };

  Color _borderColor(ColorScheme colorScheme) => switch (day.state) {
    WeekDayState.completed || WeekDayState.planned => colorScheme.primary,
    WeekDayState.missed => colorScheme.error,
    WeekDayState.rest => colorScheme.outline,
  };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Expanded(
      child: Semantics(
        button: true,
        selected: isSelected,
        label: context.l10n.homeWeekDaySemantics(
          label,
          _statusText(context.l10n),
        ),
        excludeSemantics: true,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppRadius.control),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
            child: Column(
              children: [
                Text(
                  label,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: day.isToday || isSelected
                        ? colorScheme.primary
                        : colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                _buildMarker(colorScheme),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMarker(ColorScheme colorScheme) {
    final isDone = day.state == WeekDayState.completed;

    return Container(
      width: _markerSize,
      height: _markerSize,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isDone ? colorScheme.primary : null,
        border: Border.all(
          color: _borderColor(colorScheme),
          width: day.isToday || isSelected ? _emphasizedBorderWidth : 1,
        ),
      ),
      child: isDone
          ? Icon(
              Icons.check,
              size: AppIconSize.inline,
              color: colorScheme.onPrimary,
            )
          : day.state == WeekDayState.missed
          ? Icon(
              Icons.close,
              size: AppIconSize.inline,
              color: colorScheme.error,
            )
          : null,
    );
  }
}
