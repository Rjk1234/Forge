import 'package:flutter/material.dart';
import 'package:forge/core/theme/app_dimensions.dart';
import 'package:forge/core/widgets/app_card.dart';
import 'package:forge/core/widgets/shimmer_animation.dart';
import 'package:forge/core/widgets/shimmer_box.dart';

/// Placeholder rows shown while history is being read.
class HistorySkeleton extends StatelessWidget {
  const HistorySkeleton({super.key});

  static const int _rowCount = 7;

  @override
  Widget build(BuildContext context) {
    return ShimmerAnimation(
      builder: (context, animation) {
        return ListView.separated(
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lgx),
          itemCount: _rowCount,
          separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.sm),
          itemBuilder: (_, _) => HistorySkeletonRow(animation: animation),
        );
      },
    );
  }
}

/// A single placeholder shaped like a history card.
class HistorySkeletonRow extends StatelessWidget {
  const HistorySkeletonRow({required this.animation, super.key});

  static const double _radius = AppRadius.card;
  static const double _horizontalPadding = AppSpacing.mdl;
  static const double _verticalPadding = AppSpacing.md;
  static const double _gap = AppSpacing.md;
  static const double _badgeWidth = 44;
  static const double _badgeHeight = 34;
  static const double _badgeRadius = AppRadius.small;
  static const double _lineHeight = 14;
  static const double _lineRadius = 6;

  final Animation<double> animation;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      radius: _radius,
      padding: const EdgeInsets.symmetric(
        horizontal: _horizontalPadding,
        vertical: _verticalPadding,
      ),
      child: Row(
        children: [
          ShimmerBox(
            animation: animation,
            width: _badgeWidth,
            height: _badgeHeight,
            borderRadius: _badgeRadius,
          ),
          const SizedBox(width: _gap),
          Expanded(
            child: ShimmerBox(
              animation: animation,
              height: _lineHeight,
              borderRadius: _lineRadius,
            ),
          ),
        ],
      ),
    );
  }
}
