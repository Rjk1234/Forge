import 'package:flutter/material.dart';
import 'package:forge/core/theme/app_dimensions.dart';
import 'package:forge/core/widgets/shimmer_animation.dart';
import 'package:forge/core/widgets/shimmer_box.dart';
import 'package:forge/features/workout_plan/presentation/widgets/plan_detail_skeleton_card.dart';

class PlanDetailSkeleton extends StatelessWidget {
  const PlanDetailSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return ShimmerAnimation(
      builder: (context, animation) {
        final colorScheme = Theme.of(context).colorScheme;
        return CustomScrollView(
          slivers: [
            SliverAppBar(
              pinned: true,
              backgroundColor: colorScheme.surfaceContainerLowest,
              leading: Icon(
                Icons.arrow_back_ios_new,
                color: colorScheme.onSurface,
              ),
              flexibleSpace: FlexibleSpaceBar(
                titlePadding: const EdgeInsets.fromLTRB(
                  56,
                  0,
                  56,
                  AppSpacing.lg,
                ),
                title: ShimmerBox(
                  animation: animation,
                  width: 160,
                  height: 18,
                  borderRadius: 4,
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.lgx,
                AppSpacing.lg,
                0,
              ),
              sliver: SliverToBoxAdapter(
                child: ShimmerBox(
                  animation: animation,
                  width: 70,
                  height: 10,
                  borderRadius: 4,
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.md,
                AppSpacing.lg,
                100,
              ),
              sliver: SliverList.builder(
                itemCount: 4,
                itemBuilder: (_, _) =>
                    PlanDetailSkeletonCard(animation: animation),
              ),
            ),
          ],
        );
      },
    );
  }
}
