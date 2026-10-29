import 'package:flutter/material.dart';
import 'package:forge/core/theme/app_dimensions.dart';
import 'package:forge/core/theme/app_colors_extension.dart';

class ProfileFieldGroup extends StatelessWidget {
  const ProfileFieldGroup({
    required this.label,
    required this.child,
    super.key,
  });

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final appColors = AppColorsExtension.of(context);
    final textTheme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: textTheme.labelMedium?.copyWith(color: appColors.textDim),
        ),
        const SizedBox(height: AppSpacing.sm),
        child,
      ],
    );
  }
}
