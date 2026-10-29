import 'package:flutter/material.dart';
import 'package:forge/core/theme/app_dimensions.dart';
import 'package:forge/core/widgets/shimmer_animation.dart';
import 'package:forge/core/widgets/shimmer_box.dart';

/// Placeholder mirroring the Stats layout while data is calculated.
class StatsSkeleton extends StatelessWidget {
  const StatsSkeleton({super.key});

  static const double _horizontalPadding = AppSpacing.lgx;
  static const double _gap = AppSpacing.smd;
  static const double _sectionGap = AppSpacing.lg;
  static const double _tileHeight = 88;
  static const double _rowHeight = 56;
  static const double _radius = AppRadius.card;
  static const int _exerciseRowCount = 3;

  @override
  Widget build(BuildContext context) {
    return ShimmerAnimation(
      builder: (context, animation) {
        Widget tile() => ShimmerBox(
          animation: animation,
          height: _tileHeight,
          borderRadius: _radius,
        );

        return ListView(
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: _horizontalPadding),
          children: [
            Row(
              children: [
                Expanded(child: tile()),
                const SizedBox(width: _gap),
                Expanded(child: tile()),
              ],
            ),
            const SizedBox(height: _gap),
            Row(
              children: [
                Expanded(child: tile()),
                const SizedBox(width: _gap),
                Expanded(child: tile()),
              ],
            ),
            const SizedBox(height: _sectionGap),
            for (var i = 0; i < _exerciseRowCount; i++) ...[
              ShimmerBox(
                animation: animation,
                height: _rowHeight,
                borderRadius: _radius,
              ),
              const SizedBox(height: _gap),
            ],
          ],
        );
      },
    );
  }
}
