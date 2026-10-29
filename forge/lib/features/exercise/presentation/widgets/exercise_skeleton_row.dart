import 'package:flutter/material.dart';
import 'package:forge/core/theme/app_dimensions.dart';
import 'package:forge/core/widgets/shimmer_box.dart';

class ExerciseSkeletonRow extends StatelessWidget {
  const ExerciseSkeletonRow({required this.animation, super.key});

  final Animation<double> animation;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.smd,
      ),
      child: Row(
        children: [
          ShimmerBox(
            animation: animation,
            width: 7,
            height: 7,
            borderRadius: 4,
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ShimmerBox(animation: animation, height: 14, borderRadius: 4),
                const SizedBox(height: AppSpacing.xsm),
                ShimmerBox(
                  animation: animation,
                  width: 80,
                  height: 11,
                  borderRadius: 4,
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
    );
  }
}
