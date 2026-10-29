import 'package:flutter/material.dart';
import 'package:forge/core/theme/app_dimensions.dart';
import 'package:forge/core/widgets/app_card.dart';
import 'package:forge/core/theme/app_colors_extension.dart';

/// One aggregate statistic: icon, headline value and label.
class StatsMetricTile extends StatelessWidget {
  const StatsMetricTile({
    required this.icon,
    required this.value,
    required this.label,
    this.isDimmed = false,
    super.key,
  });

  static const double _radius = AppRadius.card;
  static const double _padding = AppSpacing.mdl;
  static const double _gap = AppSpacing.xsm;
  static const double _iconWrapSize = 28;
  static const double _iconWrapRadius = AppRadius.small;
  static const double _iconSize = 15;
  static const double _dimmedOpacity = 0.55;

  final IconData icon;
  final String value;
  final String label;

  /// Muted look for the empty state (placeholder values).
  final bool isDimmed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final appColors = AppColorsExtension.of(context);
    final textTheme = theme.textTheme;

    return Opacity(
      opacity: isDimmed ? _dimmedOpacity : 1,
      child: AppCard(
        radius: _radius,
        padding: const EdgeInsets.all(_padding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: _iconWrapSize,
              height: _iconWrapSize,
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(_iconWrapRadius),
              ),
              child: Icon(
                icon,
                size: _iconSize,
                color: isDimmed ? appColors.textDim : colorScheme.primary,
              ),
            ),
            const SizedBox(height: _gap),
            Text(
              value,
              style: textTheme.displayMedium?.copyWith(
                color: isDimmed ? appColors.textDim : colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: _gap),
            Text(label, style: textTheme.bodySmall),
          ],
        ),
      ),
    );
  }
}
