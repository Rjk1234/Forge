import 'package:flutter/material.dart';
import 'package:forge/core/theme/app_dimensions.dart';
import 'package:forge/core/widgets/shimmer_animation.dart';
import 'package:forge/features/exercise/presentation/widgets/exercise_skeleton_chips_row.dart';
import 'package:forge/features/exercise/presentation/widgets/exercise_skeleton_row.dart';
import 'package:forge/features/exercise/presentation/widgets/exercise_skeleton_search_bar.dart';

class ExerciseSkeletonList extends StatelessWidget {
  const ExerciseSkeletonList({super.key});

  @override
  Widget build(BuildContext context) {
    return ShimmerAnimation(
      builder: (context, animation) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ExerciseSkeletonSearchBar(animation: animation),
          const SizedBox(height: AppSpacing.md),
          ExerciseSkeletonChipsRow(animation: animation),
          const SizedBox(height: AppSpacing.sm),
          Expanded(
            child: ListView.builder(
              physics: const NeverScrollableScrollPhysics(),
              itemCount: 6,
              itemBuilder: (_, _) => ExerciseSkeletonRow(animation: animation),
            ),
          ),
        ],
      ),
    );
  }
}
