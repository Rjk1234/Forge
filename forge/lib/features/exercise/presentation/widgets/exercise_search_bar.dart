import 'package:flutter/material.dart';
import 'package:forge/core/theme/app_dimensions.dart';
import 'package:forge/l10n/l10n.dart';
import 'package:forge/core/theme/app_colors_extension.dart';

class ExerciseSearchBar extends StatelessWidget {
  const ExerciseSearchBar({
    required this.controller,
    required this.isActive,
    required this.onChanged,
    super.key,
  });

  final TextEditingController controller;
  final bool isActive;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final appColors = AppColorsExtension.of(context);
    final textTheme = theme.textTheme;
    final borderColor = isActive ? colorScheme.primary : colorScheme.outline;
    final iconColor = isActive ? colorScheme.primary : appColors.textDim;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.md,
        AppSpacing.lg,
        0,
      ),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        style: textTheme.bodyLarge?.copyWith(color: colorScheme.onSurface),
        decoration: InputDecoration(
          hintText: context.l10n.exerciseSearchHint,
          hintStyle: textTheme.bodyLarge?.copyWith(color: appColors.textDim),
          prefixIcon: Icon(Icons.search, color: iconColor, size: 20),
          suffixIcon: controller.text.isNotEmpty
              ? GestureDetector(
                  onTap: () {
                    controller.clear();
                    onChanged('');
                  },
                  child: Icon(Icons.close, color: appColors.textDim, size: 18),
                )
              : null,
          filled: true,
          fillColor: colorScheme.surfaceContainerHighest,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: 0,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppRadius.control),
            borderSide: BorderSide(color: borderColor),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppRadius.control),
            borderSide: BorderSide(color: borderColor),
          ),
        ),
      ),
    );
  }
}
