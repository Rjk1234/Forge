import 'package:flutter/material.dart';
import 'package:forge/core/theme/app_dimensions.dart';
import 'package:forge/core/widgets/app_card.dart';

/// Direction of a tile's change since the previous session.
enum DeltaTrend { up, down, none }

/// One metric of the latest session with its change since the previous one.
class StatTile extends StatelessWidget {
  const StatTile({
    required this.label,
    required this.value,
    required this.delta,
    required this.trend,
    super.key,
  });

  static const double _radius = AppRadius.card;
  static const double _padding = AppSpacing.md;
  static const double _valueGap = AppSpacing.xs;
  static const double _deltaGap = AppSpacing.xxs;

  final String label;
  final String value;

  /// Already signed, e.g. "+5 kg" or "-2".
  final String delta;
  final DeltaTrend trend;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return AppCard(
      radius: _radius,
      padding: const EdgeInsets.all(_padding),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label.toUpperCase(),
            textAlign: TextAlign.center,
            style: textTheme.labelSmall,
          ),
          const SizedBox(height: _valueGap),
          Text(
            value,
            textAlign: TextAlign.center,
            style: textTheme.displaySmall,
          ),
          const SizedBox(height: _deltaGap),
          Text(
            delta,
            textAlign: TextAlign.center,
            style: textTheme.labelMedium?.copyWith(
              color: switch (trend) {
                DeltaTrend.up => colorScheme.primary,
                DeltaTrend.down => colorScheme.error,
                DeltaTrend.none => colorScheme.onSurfaceVariant,
              },
            ),
          ),
        ],
      ),
    );
  }
}
