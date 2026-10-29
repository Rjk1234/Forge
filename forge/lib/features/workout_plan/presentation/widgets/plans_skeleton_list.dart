import 'package:flutter/material.dart';
import 'package:forge/core/widgets/shimmer_animation.dart';
import 'package:forge/features/workout_plan/presentation/widgets/plans_skeleton_card.dart';

class PlansSkeletonList extends StatelessWidget {
  const PlansSkeletonList({super.key});

  @override
  Widget build(BuildContext context) {
    return ShimmerAnimation(
      builder: (context, animation) => ListView.builder(
        physics: const NeverScrollableScrollPhysics(),
        itemCount: 4,
        itemBuilder: (_, _) => PlansSkeletonCard(animation: animation),
      ),
    );
  }
}
