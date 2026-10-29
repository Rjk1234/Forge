import 'package:flutter/material.dart';
import 'package:forge/core/theme/app_dimensions.dart';
import 'package:forge/core/widgets/shimmer_box.dart';

class PlanDetailSkeletonCard extends StatelessWidget {
  const PlanDetailSkeletonCard({required this.animation, super.key});

  final Animation<double> animation;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(AppRadius.banner),
          border: Border.all(color: colorScheme.outline),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTitleRow(),
            const SizedBox(height: AppSpacing.md),
            _buildBlocksRow(),
          ],
        ),
      ),
    );
  }

  Widget _buildTitleRow() {
    return Row(
      children: [
        ShimmerBox(animation: animation, width: 7, height: 7, borderRadius: 4),
        const SizedBox(width: AppSpacing.xsm),
        ShimmerBox(
          animation: animation,
          width: 52,
          height: 10,
          borderRadius: 4,
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: ShimmerBox(
            animation: animation,
            height: 14,
            borderRadius: 4,
            widthFraction: 0.65,
          ),
        ),
      ],
    );
  }

  Widget _buildBlocksRow() {
    return Row(
      children: [
        _buildBlock(),
        const SizedBox(width: AppSpacing.sm),
        _buildBlock(),
        const SizedBox(width: AppSpacing.sm),
        _buildBlock(),
      ],
    );
  }

  Widget _buildBlock() {
    return Expanded(
      child: ShimmerBox(animation: animation, height: 44, borderRadius: 8),
    );
  }
}
