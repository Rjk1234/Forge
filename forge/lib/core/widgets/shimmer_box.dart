import 'package:flutter/material.dart';
import 'package:forge/core/theme/app_colors_extension.dart';

/// Animated shimmer placeholder box used in skeleton screens.
///
/// Lerps between the surface-container and shimmer-highlight theme colors driven by
/// [animation]. Either [width] or [widthFraction] (fraction of parent width)
/// controls horizontal size; omitting both fills the parent.
class ShimmerBox extends StatelessWidget {
  const ShimmerBox({
    required this.animation,
    required this.height,
    required this.borderRadius,
    this.width,
    this.widthFraction,
    super.key,
  });

  final Animation<double> animation;
  final double height;
  final double borderRadius;
  final double? width;
  final double? widthFraction;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final appColors = AppColorsExtension.of(context);
    return LayoutBuilder(
      builder: (context, constraints) {
        final resolvedWidth =
            width ??
            (widthFraction != null
                ? constraints.maxWidth * widthFraction!
                : null);
        return AnimatedBuilder(
          animation: animation,
          builder: (_, _) {
            final t =
                (animation.value < 0.5
                    ? animation.value
                    : 1 - animation.value) *
                2;
            final shimmerColor = Color.lerp(
              colorScheme.surfaceContainerHighest,
              appColors.shimmerHighlight,
              t,
            )!;
            return Container(
              width: resolvedWidth,
              height: height,
              decoration: BoxDecoration(
                color: shimmerColor,
                borderRadius: BorderRadius.circular(borderRadius),
              ),
            );
          },
        );
      },
    );
  }
}
