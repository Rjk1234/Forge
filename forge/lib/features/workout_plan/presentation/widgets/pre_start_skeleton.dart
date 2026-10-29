import 'package:flutter/material.dart';
import 'package:forge/core/theme/app_dimensions.dart';
import 'package:forge/core/widgets/shimmer_animation.dart';
import 'package:forge/core/widgets/shimmer_box.dart';
import 'package:forge/l10n/l10n.dart';
import 'package:forge/features/workout_plan/presentation/widgets/pre_start_skeleton_card.dart';
import 'package:forge/features/workout_plan/presentation/widgets/pre_start_skeleton_header.dart';

class PreStartSkeleton extends StatelessWidget {
  const PreStartSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return ShimmerAnimation(
      builder: (context, animation) {
        final colorScheme = Theme.of(context).colorScheme;
        return Semantics(
          label: context.l10n.preStartLoadingSemantics,
          child: CustomScrollView(
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
                    width: 120,
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
                  child: PreStartSkeletonHeader(animation: animation),
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
                      PreStartSkeletonCard(animation: animation),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
