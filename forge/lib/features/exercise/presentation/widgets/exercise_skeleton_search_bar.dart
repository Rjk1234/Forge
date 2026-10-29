import 'package:flutter/material.dart';
import 'package:forge/core/theme/app_dimensions.dart';
import 'package:forge/core/widgets/shimmer_box.dart';

class ExerciseSkeletonSearchBar extends StatelessWidget {
  const ExerciseSkeletonSearchBar({required this.animation, super.key});

  final Animation<double> animation;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.md,
        AppSpacing.lg,
        0,
      ),
      child: ShimmerBox(animation: animation, height: 44, borderRadius: 10),
    );
  }
}
