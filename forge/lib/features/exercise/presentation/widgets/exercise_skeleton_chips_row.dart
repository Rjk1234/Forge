import 'package:flutter/material.dart';
import 'package:forge/core/theme/app_dimensions.dart';
import 'package:forge/core/widgets/shimmer_box.dart';

class ExerciseSkeletonChipsRow extends StatelessWidget {
  const ExerciseSkeletonChipsRow({required this.animation, super.key});

  final Animation<double> animation;

  @override
  Widget build(BuildContext context) {
    const widths = [40.0, 80.0, 90.0, 90.0];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Row(
        children: [
          for (var i = 0; i < widths.length; i++) ...[
            ShimmerBox(
              animation: animation,
              width: widths[i],
              height: 32,
              borderRadius: 16,
            ),
            if (i < widths.length - 1) const SizedBox(width: AppSpacing.sm),
          ],
        ],
      ),
    );
  }
}
