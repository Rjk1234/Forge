import 'package:flutter/material.dart';
import 'package:forge/core/theme/app_dimensions.dart';
import 'package:forge/core/widgets/shimmer_box.dart';

class PlansSkeletonCard extends StatelessWidget {
  const PlansSkeletonCard({required this.animation, super.key});

  final Animation<double> animation;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.sm,
      ),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(AppRadius.sheet),
          border: Border.all(color: colorScheme.outline),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ShimmerBox(
                    animation: animation,
                    height: 15,
                    borderRadius: 4,
                    widthFraction: 0.65,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  ShimmerBox(
                    animation: animation,
                    height: 11,
                    borderRadius: 4,
                    widthFraction: 0.32,
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            ShimmerBox(
              animation: animation,
              width: 20,
              height: 20,
              borderRadius: 4,
            ),
          ],
        ),
      ),
    );
  }
}
