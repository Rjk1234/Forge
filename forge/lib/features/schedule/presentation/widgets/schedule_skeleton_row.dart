import 'package:flutter/material.dart';
import 'package:forge/core/theme/app_dimensions.dart';
import 'package:forge/core/widgets/shimmer_box.dart';

class ScheduleSkeletonRow extends StatelessWidget {
  const ScheduleSkeletonRow({required this.animation, super.key});

  final Animation<double> animation;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        ShimmerBox(
          animation: animation,
          height: 52,
          borderRadius: 8,
          width: 44,
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ShimmerBox(
                animation: animation,
                height: 14,
                borderRadius: 4,
                widthFraction: 0.55,
              ),
              const SizedBox(height: AppSpacing.xsm),
              ShimmerBox(
                animation: animation,
                height: 11,
                borderRadius: 4,
                widthFraction: 0.35,
              ),
            ],
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        ShimmerBox(
          animation: animation,
          height: 32,
          borderRadius: 6,
          width: 60,
        ),
      ],
    );
  }
}
