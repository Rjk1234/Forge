import 'package:flutter/material.dart';
import 'package:forge/core/theme/app_dimensions.dart';
import 'package:flutter/services.dart';
import 'package:forge/core/theme/app_colors_extension.dart';

/// A single numeric input cell: label above, value text field below.
/// Used inside [ExerciseCard] for Sets, Reps/Duration, Weight, and Rest.
class ExerciseFieldBox extends StatelessWidget {
  const ExerciseFieldBox({
    required this.label,
    required this.controller,
    required this.onChanged,
    this.keyboardType = TextInputType.number,
    this.inputFormatters = const [],
    this.hasError = false,
    this.errorText,
    super.key,
  });

  final String label;
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final TextInputType keyboardType;
  final List<TextInputFormatter> inputFormatters;
  final bool hasError;

  /// Message shown under the box. Leave null where the box is too narrow for
  /// it (the plan form shows one message per exercise card instead).
  final String? errorText;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final appColors = AppColorsExtension.of(context);
    final textTheme = theme.textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: textTheme.labelSmall?.copyWith(
            color: hasError ? colorScheme.error : appColors.textDim,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        TextField(
          controller: controller,
          onChanged: onChanged,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          textAlign: TextAlign.center,
          style: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurface),
          decoration: InputDecoration(
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(
              vertical: AppSpacing.sm,
              horizontal: AppSpacing.xs,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: BorderSide(
                color: hasError ? colorScheme.error : colorScheme.outline,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: BorderSide(
                color: hasError ? colorScheme.error : colorScheme.primary,
                width: 2,
              ),
            ),
          ),
        ),
        if (errorText != null) ...[
          const SizedBox(height: AppSpacing.xxs),
          Text(
            errorText!,
            style: textTheme.labelMedium?.copyWith(color: colorScheme.error),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ],
    );
  }
}
