import 'package:flutter/material.dart';
import 'package:forge/core/theme/app_dimensions.dart';
import 'package:forge/core/widgets/app_card.dart';
import 'package:forge/core/widgets/shimmer_animation.dart';
import 'package:forge/core/widgets/shimmer_box.dart';

/// Placeholder mirroring the Progress layout while data is read.
class ProgressSkeleton extends StatelessWidget {
  const ProgressSkeleton({super.key});

  static const double _sectionGap = AppSpacing.lg;
  static const double _itemGap = AppSpacing.sm;
  static const double _statGap = AppSpacing.smd;
  static const double _chipWidth = 84;
  static const double _chipHeight = 32;
  static const double _chipRadius = 20;
  static const double _cardRadius = AppRadius.sheet;
  static const double _cardPadding = AppSpacing.lg;
  static const double _chartHeight = 150;
  static const double _chartRadius = AppRadius.control;
  static const double _statHeight = 66;
  static const double _statRadius = AppRadius.card;
  static const int _chipCount = 3;
  static const int _statCount = 3;

  @override
  Widget build(BuildContext context) {
    return ShimmerAnimation(
      builder: (context, animation) {
        return ListView(
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lgx),
          children: [
            Row(
              children: [
                for (var i = 0; i < _chipCount; i++) ...[
                  if (i > 0) const SizedBox(width: _itemGap),
                  ShimmerBox(
                    animation: animation,
                    width: _chipWidth,
                    height: _chipHeight,
                    borderRadius: _chipRadius,
                  ),
                ],
              ],
            ),
            const SizedBox(height: _sectionGap),
            AppCard(
              radius: _cardRadius,
              padding: const EdgeInsets.all(_cardPadding),
              child: ShimmerBox(
                animation: animation,
                height: _chartHeight,
                borderRadius: _chartRadius,
              ),
            ),
            const SizedBox(height: _sectionGap),
            Row(
              children: [
                for (var i = 0; i < _statCount; i++) ...[
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
          ],
        );
      },
    );
  }
}
