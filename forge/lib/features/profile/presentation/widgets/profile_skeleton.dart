import 'package:flutter/material.dart';
import 'package:forge/core/theme/app_dimensions.dart';

import 'package:forge/core/widgets/shimmer_animation.dart';
import 'package:forge/core/widgets/shimmer_box.dart';

class ProfileSkeleton extends StatelessWidget {
  const ProfileSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return ShimmerAnimation(
      period: const Duration(milliseconds: 1200),
      builder: (context, animation) {
        final colorScheme = Theme.of(context).colorScheme;
        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.xl,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: ShimmerBox(
                  animation: animation,
                  height: 72,
                  borderRadius: 36,
                  width: 72,
                ),
              ),
              const SizedBox(height: AppSpacing.xxl),
              ..._labeledField(animation, 0.35),
              const SizedBox(height: AppSpacing.xl),
              ..._labeledField(animation, 0.4),
              const SizedBox(height: AppSpacing.xl),
              ..._labeledField(animation, 0.45),
              const SizedBox(height: AppSpacing.xl),
              _buildFieldPair(animation),
              const SizedBox(height: AppSpacing.xxl),
              _field(animation),
              const SizedBox(height: AppSpacing.xl),
              Container(height: 1, color: colorScheme.outline),
              const SizedBox(height: AppSpacing.xl),
              _field(animation),
            ],
          ),
        );
      },
    );
  }

  Widget _field(Animation<double> animation) {
    return ShimmerBox(animation: animation, height: 48, borderRadius: 8);
  }

  List<Widget> _labeledField(
    Animation<double> animation,
    double labelWidthFraction,
  ) {
    return [
      ShimmerBox(
        animation: animation,
        height: 14,
        borderRadius: 6,
        widthFraction: labelWidthFraction,
      ),
      const SizedBox(height: AppSpacing.sm),
      _field(animation),
    ];
  }

  Widget _buildFieldPair(Animation<double> animation) {
    return Row(
      children: [
        Expanded(child: _field(animation)),
        const SizedBox(width: AppSpacing.md),
        Expanded(child: _field(animation)),
      ],
    );
  }
}
