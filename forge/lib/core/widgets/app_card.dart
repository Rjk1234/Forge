import 'package:flutter/material.dart';
import 'package:forge/core/theme/app_dimensions.dart';
import 'package:forge/core/widgets/full_width.dart';

/// Bordered surface used for every card-like block in the app.
class AppCard extends StatelessWidget {
  const AppCard({
    required this.child,
    this.padding = const EdgeInsets.all(AppSpacing.md),
    this.radius = AppRadius.card,
    this.color,
    this.borderColor,
    this.isFullWidth = false,
    this.margin,
    super.key,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final double radius;

  /// Defaults to the theme surface colour.
  final Color? color;

  /// Defaults to the theme outline colour.
  final Color? borderColor;
  final bool isFullWidth;
  final EdgeInsetsGeometry? margin;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final card = Container(
      margin: margin,
      padding: padding,
      decoration: BoxDecoration(
        color: color ?? colorScheme.surface,
        border: Border.all(color: borderColor ?? colorScheme.outline),
        borderRadius: BorderRadius.circular(radius),
      ),
      child: child,
    );
    return isFullWidth ? FullWidth(child: card) : card;
  }
}
