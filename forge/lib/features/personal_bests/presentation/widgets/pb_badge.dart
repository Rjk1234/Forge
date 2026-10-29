import 'package:flutter/material.dart';
import 'package:forge/core/theme/app_dimensions.dart';

/// Best value with a small caption, shown at the right of a PB card.
class PbBadge extends StatelessWidget {
  const PbBadge({required this.value, required this.label, super.key});

  static const double _radius = AppRadius.control;
  static const double _horizontalPadding = AppSpacing.md;
  static const double _verticalPadding = AppSpacing.sm;
  static const double _labelGap = 1;

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: _horizontalPadding,
        vertical: _verticalPadding,
      ),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        border: Border.all(color: colorScheme.outline),
        borderRadius: BorderRadius.circular(_radius),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(value, style: textTheme.titleMedium),
          const SizedBox(height: _labelGap),
          Text(label.toUpperCase(), style: textTheme.labelSmall),
        ],
      ),
    );
  }
}
