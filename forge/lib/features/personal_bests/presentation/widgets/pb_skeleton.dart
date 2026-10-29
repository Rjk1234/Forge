import 'package:flutter/material.dart';
import 'package:forge/core/theme/app_dimensions.dart';
import 'package:forge/core/widgets/app_card.dart';
import 'package:forge/core/widgets/shimmer_animation.dart';
import 'package:forge/core/widgets/shimmer_box.dart';

/// Placeholder rows shown while personal bests are calculated.
class PbSkeleton extends StatelessWidget {
  const PbSkeleton({super.key});

  static const int _rowCount = 5;

  @override
  Widget build(BuildContext context) {
    return ShimmerAnimation(
      builder: (context, animation) {
        return ListView.separated(
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lgx,
            18,
            AppSpacing.lgx,
            28,
          ),
          itemCount: _rowCount,
          separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.smd),
          itemBuilder: (_, _) => PbSkeletonRow(animation: animation),
        );
      },
    );
  }
}

/// One placeholder shaped like a PB card.
class PbSkeletonRow extends StatelessWidget {
  const PbSkeletonRow({required this.animation, super.key});

  static const double _radius = AppRadius.card;
  static const double _horizontalPadding = AppSpacing.mdl;
  static const double _verticalPadding = AppSpacing.md;
  static const double _gap = AppSpacing.md;
  static const double _dotSize = 8;
  static const double _lineHeight = 14;
  static const double _lineRadius = 6;
  static const double _badgeWidth = 56;
  static const double _badgeHeight = 38;
  static const double _badgeRadius = AppRadius.control;

  final Animation<double> animation;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return AppCard(
      radius: _radius,
      padding: const EdgeInsets.symmetric(
        horizontal: _horizontalPadding,
        vertical: _verticalPadding,
      ),
      child: Row(
        children: [
          Container(
            width: _dotSize,
            height: _dotSize,
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: _gap),
          Expanded(
            child: ShimmerBox(
              animation: animation,
              height: _lineHeight,
              borderRadius: _lineRadius,
            ),
          ),
          const SizedBox(width: _gap),
          ShimmerBox(
            animation: animation,
            width: _badgeWidth,
            height: _badgeHeight,
            borderRadius: _badgeRadius,
          ),
        ],
      ),
    );
  }
}
