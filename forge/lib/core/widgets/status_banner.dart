import 'package:flutter/material.dart';
import 'package:forge/core/widgets/full_width.dart';
import 'package:forge/core/theme/app_colors_extension.dart';
import 'package:forge/core/theme/app_dimensions.dart';

/// Inline error or warning message with an optional second line.
///
/// A lone [message] is shown in the error colour; with a [subtitle] the
/// message becomes the neutral headline and the subtitle explains it.
class StatusBanner extends StatelessWidget {
  const StatusBanner({
    required this.message,
    this.subtitle,
    this.icon = Icons.error_outline,
    this.emphasizeBorder = false,
    this.margin = EdgeInsets.zero,
    super.key,
  });

  static const double _iconTopOffset = 1;
  static const double _emphasizedBorderWidth = 1.5;

  final String message;
  final String? subtitle;
  final IconData icon;

  /// Uses the stronger error border instead of the soft danger border.
  final bool emphasizeBorder;
  final EdgeInsetsGeometry margin;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final appColors = AppColorsExtension.of(context);

    return Semantics(
      liveRegion: true,
      child: FullWidth(
        child: Container(
          margin: margin,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.md,
          ),
          decoration: BoxDecoration(
            color: colorScheme.errorContainer,
            border: Border.all(
              color: emphasizeBorder
                  ? colorScheme.error
                  : appColors.dangerBorder,
              width: emphasizeBorder ? _emphasizedBorderWidth : 1,
            ),
            borderRadius: BorderRadius.circular(AppRadius.banner),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: _iconTopOffset),
                child: Icon(
                  icon,
                  color: colorScheme.error,
                  size: AppIconSize.inline,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(child: _buildText(context)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildText(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final detail = subtitle;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          message,
          style: textTheme.bodySmall?.copyWith(
            color: detail == null ? colorScheme.error : colorScheme.onSurface,
          ),
        ),
        if (detail != null) ...[
          const SizedBox(height: AppSpacing.xxs),
          Text(
            detail,
            style: textTheme.labelSmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ],
    );
  }
}
