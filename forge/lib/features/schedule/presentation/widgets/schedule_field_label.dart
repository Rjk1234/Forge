import 'package:flutter/material.dart';
import 'package:forge/core/theme/app_dimensions.dart';
import 'package:forge/core/theme/app_colors_extension.dart';
import 'package:forge/core/theme/app_text_extension.dart';

class ScheduleFieldLabel extends StatelessWidget {
  const ScheduleFieldLabel(this.label, {super.key});

  final String label;

  @override
  Widget build(BuildContext context) {
    final textStyles = AppTextExtension.of(context);
    final appColors = AppColorsExtension.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Text(
        label,
        style: textStyles.overline.copyWith(color: appColors.textDim),
      ),
    );
  }
}
