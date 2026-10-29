import 'package:flutter/material.dart';
import 'package:forge/core/theme/app_dimensions.dart';
import 'package:forge/core/widgets/shimmer_animation.dart';
import 'package:forge/features/schedule/presentation/widgets/schedule_skeleton_row.dart';

class ScheduleSkeletonList extends StatelessWidget {
  const ScheduleSkeletonList({super.key});

  @override
  Widget build(BuildContext context) {
    return ShimmerAnimation(
      builder: (context, animation) => ListView.separated(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        itemCount: 7,
        separatorBuilder: (context, index) =>
            const SizedBox(height: AppSpacing.md),
        itemBuilder: (context, index) =>
            ScheduleSkeletonRow(animation: animation),
      ),
    );
  }
}
