import 'package:flutter/material.dart';
import 'package:forge/core/theme/app_dimensions.dart';
import 'package:forge/core/widgets/shimmer_box.dart';

class PreStartSkeletonHeader extends StatelessWidget {
  const PreStartSkeletonHeader({required this.animation, super.key});

  final Animation<double> animation;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ShimmerBox(
          animation: animation,
          width: 180,
          height: 28,
          borderRadius: 6,
        ),
        const SizedBox(height: AppSpacing.sm),
        ShimmerBox(
          animation: animation,
          width: 130,
          height: 12,
          borderRadius: 4,
        ),
        const SizedBox(height: AppSpacing.xl),
        ShimmerBox(
          animation: animation,
          width: 80,
          height: 10,
          borderRadius: 4,
        ),
      ],
    );
  }
}
