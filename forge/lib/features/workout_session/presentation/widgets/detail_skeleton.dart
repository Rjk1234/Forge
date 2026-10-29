import 'package:flutter/material.dart';
import 'package:forge/core/theme/app_dimensions.dart';
import 'package:forge/core/widgets/app_card.dart';
import 'package:forge/core/widgets/shimmer_animation.dart';
import 'package:forge/core/widgets/shimmer_box.dart';

/// Placeholder shaped like the workout detail while the session is read.
class DetailSkeleton extends StatelessWidget {
  const DetailSkeleton({super.key});

  static const double _horizontalPadding = AppSpacing.lgx;
  static const double _verticalPadding = AppSpacing.mdl;
  static const double _sectionGap = AppSpacing.lg;
  static const double _statGap = AppSpacing.smd;
  static const double _titleWidthFraction = 0.7;
  static const double _titleHeight = 22;
  static const double _subWidthFraction = 0.45;
  static const double _subHeight = 12;
  static const double _subTopGap = AppSpacing.sm;
  static const double _lineRadius = 6;
  static const double _statHeight = 58;
  static const double _statRadius = AppRadius.card;
  static const List<int> _pillCountsPerCard = [3, 2, 3];

  @override
  Widget build(BuildContext context) {
    return ShimmerAnimation(
      builder: (context, animation) {
        return ListView(
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(
            horizontal: _horizontalPadding,
            vertical: _verticalPadding,
          ),
          children: [
            ShimmerBox(
              animation: animation,
              widthFraction: _titleWidthFraction,
              height: _titleHeight,
              borderRadius: _lineRadius,
            ),
            const SizedBox(height: _subTopGap),
            ShimmerBox(
              animation: animation,
              widthFraction: _subWidthFraction,
              height: _subHeight,
              borderRadius: _lineRadius,
            ),
            const SizedBox(height: _sectionGap),
            Row(
              children: [
                for (var i = 0; i < 3; i++) ...[
                  if (i > 0) const SizedBox(width: _statGap),
                  Expanded(
                    child: ShimmerBox(
                      animation: animation,
                      height: _statHeight,
                      borderRadius: _statRadius,
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: _sectionGap),
            for (final pillCount in _pillCountsPerCard) ...[
              DetailSkeletonCard(animation: animation, pillCount: pillCount),
              const SizedBox(height: _statGap),
            ],
          ],
        );
      },
    );
  }
}

/// Placeholder for one exercise card: a heading line and a row of pills.
class DetailSkeletonCard extends StatelessWidget {
  const DetailSkeletonCard({
    required this.animation,
    required this.pillCount,
    super.key,
  });

  static const double _radius = AppRadius.card;
  static const double _padding = AppSpacing.mdl;
  static const double _gap = AppSpacing.smd;
  static const double _pillGap = AppSpacing.sm;
  static const double _headWidthFraction = 0.6;
  static const double _headHeight = 14;
  static const double _lineRadius = 6;
  static const double _pillWidth = 56;
  static const double _pillHeight = 24;
  static const double _pillRadius = AppRadius.small;

  final Animation<double> animation;
  final int pillCount;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      radius: _radius,
      padding: const EdgeInsets.all(_padding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ShimmerBox(
            animation: animation,
            widthFraction: _headWidthFraction,
            height: _headHeight,
            borderRadius: _lineRadius,
          ),
          const SizedBox(height: _gap),
          Row(
            children: [
              for (var i = 0; i < pillCount; i++) ...[
                if (i > 0) const SizedBox(width: _pillGap),
                ShimmerBox(
                  animation: animation,
                  width: _pillWidth,
                  height: _pillHeight,
                  borderRadius: _pillRadius,
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
