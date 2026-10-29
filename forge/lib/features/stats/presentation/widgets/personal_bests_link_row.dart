import 'package:flutter/material.dart';
import 'package:forge/core/theme/app_dimensions.dart';
import 'package:forge/l10n/l10n.dart';
import 'package:forge/core/theme/app_colors_extension.dart';

/// Tappable row leading to the Personal Bests screen.
class PersonalBestsLinkRow extends StatelessWidget {
  const PersonalBestsLinkRow({required this.onTap, super.key});

  static const double _radius = AppRadius.card;
  static const double _padding = AppSpacing.mdl;
  static const double _gap = AppSpacing.smd;
  static const double _iconWrapSize = 32;
  static const double _iconWrapRadius = AppRadius.small;
  static const double _iconSize = 16;

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final appColors = AppColorsExtension.of(context);
    final textTheme = theme.textTheme;

    return Material(
      color: colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(_radius),
        side: BorderSide(color: colorScheme.outline),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(_radius),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(_padding),
          child: Row(
            children: [
              Container(
                width: _iconWrapSize,
                height: _iconWrapSize,
                decoration: BoxDecoration(
                  color: appColors.successContainer,
                  borderRadius: BorderRadius.circular(_iconWrapRadius),
                ),
                child: Icon(
                  Icons.emoji_events_outlined,
                  size: _iconSize,
                  color: colorScheme.primary,
                ),
              ),
              const SizedBox(width: _gap),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.l10n.statsPersonalBestsTitle,
                      style: textTheme.titleSmall,
                    ),
                    Text(
                      context.l10n.statsPersonalBestsSub,
                      style: textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              ExcludeSemantics(
                child: Icon(
                  Icons.chevron_right,
                  size: _iconSize,
                  color: appColors.textDim,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
